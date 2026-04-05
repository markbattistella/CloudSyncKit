//
// Project: CloudSyncKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import CoreData
import Observation

/// Monitors ``NSPersistentCloudKitContainer`` sync events and publishes the current status
/// as an observable property.
///
/// Create an instance, retain it, then call ``start()`` once to begin receiving updates.
/// The monitor automatically removes its notification observer when deallocated.
///
/// ```swift
/// @State private var monitor = CloudSyncMonitor()
///
/// var body: some View {
///     SyncStatusView(status: monitor.status)
///         .onAppear { monitor.start() }
/// }
/// ```
@MainActor
@Observable
public final class CloudSyncMonitor {

    // MARK: - Status

    /// The current synchronisation state of the CloudKit container.
    public enum Status: Equatable, Sendable {

        /// No sync event is in progress.
        case idle

        /// A sync event is in progress, described by the associated message.
        case syncing(String)

        /// The most recent sync event completed successfully.
        case success

        /// The most recent sync event failed with the associated error message.
        case failed(String)
    }

    // MARK: - Public

    /// The current sync status. Updated on the main actor whenever a CloudKit event fires.
    public private(set) var status: Status = .idle

    /// Creates a new monitor in the ``Status/idle`` state.
    public init() {}

    /// Starts observing CloudKit sync events.
    ///
    /// Safe to call multiple times; subsequent calls after the first have no effect.
    public func start() {
        guard observer == nil else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSPersistentCloudKitContainer.eventChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard
                let self,
                let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event
            else { return }

            let label: String
            switch event.type {
            case .setup:          label = "Setting up iCloud sync"
            case .import:         label = "Downloading from iCloud"
            case .export:         label = "Uploading to iCloud"
            @unknown default:     label = "Syncing"
            }

            let newStatus: Status
            if event.endDate == nil {
                newStatus = .syncing(label)
            } else if let error = event.error {
                newStatus = .failed(error.localizedDescription)
            } else {
                newStatus = event.succeeded ? .success : .idle
            }

            MainActor.assumeIsolated {
                self.status = newStatus
            }
        }
    }

    // MARK: - Private

    @ObservationIgnored nonisolated(unsafe) private var observer: NSObjectProtocol?

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
