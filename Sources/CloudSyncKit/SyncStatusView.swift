//
// Project: CloudSyncKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// The default visual representation of a ``CloudSyncMonitor/Status`` value.
///
/// Displays an icon alongside a plain-language description of the current sync state.
/// The spinning animation on the syncing icon is suppressed automatically when
/// the user has enabled Reduce Motion.
///
/// Swap this out for any type that conforms to ``CloudSyncStatusView`` if you need
/// a custom appearance.
///
/// ```swift
/// SyncStatusView(status: monitor.status)
/// ```
public struct SyncStatusView: CloudSyncStatusView {

    // MARK: - Properties

    /// The sync status this view displays.
    public let status: CloudSyncMonitor.Status

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Init

    /// Creates a status view for the given sync status.
    ///
    /// - Parameter status: The current sync status to display.
    public init(status: CloudSyncMonitor.Status) {
        self.status = status
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 8) {
            icon
                .font(.system(size: 16, weight: .semibold))
                .accessibilityHidden(true)
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(color)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(.rect(cornerRadius: 10))
        .animation(.easeInOut, value: status)
        .accessibilityLabel(title)
        .accessibilityAddTraits(.updatesFrequently)
    }

    // MARK: - Private

    private var title: String {
        switch status {
        case .idle:                return "iCloud is up to date"
        case .syncing(let msg):    return msg
        case .success:             return "Sync completed"
        case .failed(let msg):     return "Sync failed: \(msg)"
        }
    }

    @ViewBuilder
    private var icon: some View {
        switch status {
        case .idle:
            Image(systemName: "icloud")
        case .syncing:
            if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .symbolEffect(.rotate, isActive: !reduceMotion)
            } else {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
        case .success:
            Image(systemName: "checkmark.icloud.fill")
        case .failed:
            Image(systemName: "exclamationmark.icloud.fill")
        }
    }

    private var color: Color {
        switch status {
        case .idle:     return .secondary
        case .syncing:  return .blue
        case .success:  return .green
        case .failed:   return .red
        }
    }

    private var backgroundColor: Color {
        switch status {
        case .idle:     return Color.gray.opacity(0.12)
        case .syncing:  return Color.blue.opacity(0.12)
        case .success:  return Color.green.opacity(0.12)
        case .failed:   return Color.red.opacity(0.12)
        }
    }
}
