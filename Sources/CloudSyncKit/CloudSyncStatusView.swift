//
// Project: CloudSyncKit
// Author: Mark Battistella
// Website: https://markbattistella.com
//

import SwiftUI

/// A view that presents a ``CloudSyncMonitor/Status`` value to the user.
///
/// Conform to this protocol to replace the built-in ``SyncStatusView`` with your own design.
/// The single requirement is an initialiser that accepts the current status — SwiftUI's
/// observation system at the call site ensures the view is reconstructed whenever
/// ``CloudSyncMonitor/status`` changes.
///
/// ```swift
/// struct CompactSyncBadge: CloudSyncStatusView {
///     let status: CloudSyncMonitor.Status
///
///     var body: some View {
///         switch status {
///         case .syncing: ProgressView()
///         case .failed:  Image(systemName: "exclamationmark.triangle")
///         default:       EmptyView()
///         }
///     }
/// }
///
/// // Usage
/// CompactSyncBadge(status: monitor.status)
/// ```
public protocol CloudSyncStatusView: View {

    /// Creates a view for the given sync status.
    ///
    /// - Parameter status: The current sync status to display.
    init(status: CloudSyncMonitor.Status)
}
