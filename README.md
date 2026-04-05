<!-- markdownlint-disable MD033 MD041 -->
<div align="center">

# CloudSyncKit

![Swift Versions](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FCloudSyncKit%2Fbadge%3Ftype%3Dswift-versions)

![Platforms](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmarkbattistella%2FCloudSyncKit%2Fbadge%3Ftype%3Dplatforms)

![Licence](https://img.shields.io/badge/Licence-MIT-white?labelColor=blue&style=flat)

</div>

`CloudSyncKit` is a lightweight Swift package for observing `NSPersistentCloudKitContainer` sync events and surfacing the current iCloud sync status in SwiftUI.

It provides:

- An `@Observable` `CloudSyncMonitor` that tracks CloudKit sync state
- A `CloudSyncStatusView` protocol for building fully custom status UIs
- A ready-to-use `SyncStatusView` as the default implementation
- Automatic Reduce Motion support for the syncing animation
- Full Swift 6 concurrency safety

## Requirements

| Platform   | Minimum |
|------------|---------|
| iOS        | 17.0    |
| macOS      | 14.0    |
| tvOS       | 17.0    |
| watchOS    | 10.0    |
| visionOS   | 1.0     |

## Installation

Add `CloudSyncKit` to your Swift project using Swift Package Manager:

```swift
dependencies: [
  .package(url: "https://github.com/markbattistella/CloudSyncKit", from: "1.0.0")
]
```

Alternatively, add it in Xcode via `File > Add Packages` and entering the package repository URL.

## Setup

Create a `CloudSyncMonitor` instance and call `start()` when your view appears:

```swift
@State private var syncMonitor = CloudSyncMonitor()

var body: some View {
  ContentView()
    .onAppear { syncMonitor.start() }
}
```

Because `CloudSyncMonitor` is `@Observable`, you can pass it through the SwiftUI environment or inject it directly into views — SwiftUI will automatically re-render any view that reads `syncMonitor.status` when the value changes.

## Displaying Sync Status

### Default view

Pass the current status value to `SyncStatusView`:

```swift
SyncStatusView(status: syncMonitor.status)
```

The view displays an icon and a plain-language description of the current state, with four possible appearances:

| Status | Icon | Label |
| ------ | ---- | ----- |
| `.idle` | `icloud` | iCloud is up to date |
| `.syncing` | `arrow.triangle.2.circlepath` (animated) | Uploading / Downloading / Setting up |
| `.success` | `checkmark.icloud.fill` | Sync completed |
| `.failed` | `exclamationmark.icloud.fill` | Sync failed: \<message\> |

The spinning animation on `.syncing` is automatically suppressed when the user has enabled Reduce Motion.

### Example

```swift
struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [MyModel]
  @State private var syncMonitor = CloudSyncMonitor()

  var body: some View {
    NavigationStack {
      List {
        Section {
          SyncStatusView(status: syncMonitor.status)
        }
        Section("Items") {
          ForEach(items) { item in
            Text(item.name)
          }
        }
      }
      .navigationTitle("My App")
    }
    .onAppear { syncMonitor.start() }
  }
}
```

## Custom Status Views

`CloudSyncKit` uses the `CloudSyncStatusView` protocol so you can provide your own visual design while keeping the same observable-driven data flow.

Conform any SwiftUI `View` to `CloudSyncStatusView` by implementing `init(status:)`:

```swift
struct CompactSyncIndicator: CloudSyncStatusView {
  let status: CloudSyncMonitor.Status

  var body: some View {
    switch status {
    case .idle:
      EmptyView()
    case .syncing:
      ProgressView()
        .controlSize(.small)
    case .success:
      Image(systemName: "checkmark.icloud.fill")
        .foregroundStyle(.green)
    case .failed(let message):
      Label(message, systemImage: "exclamationmark.icloud.fill")
        .foregroundStyle(.red)
    }
  }
}
```

Use it exactly like the built-in view:

```swift
CompactSyncIndicator(status: syncMonitor.status)
```

Because the view receives a plain `CloudSyncMonitor.Status` value, the parent's `@Observable` observation handles all re-rendering automatically — no special wiring needed inside the custom view.

## Monitor Status Values

`CloudSyncMonitor.Status` is an equatable enum with four cases:

```swift
public enum Status: Equatable {
  case idle
  case syncing(String)   // associated message: "Uploading to iCloud" etc.
  case success
  case failed(String)    // associated message: localised error description
}
```

You can read it directly for conditional logic:

```swift
if case .failed(let message) = syncMonitor.status {
  showErrorBanner(message)
}
```

## Things to Note

- `CloudSyncMonitor.start()` is idempotent — calling it multiple times registers the notification observer only once
- Sync events are only emitted by `NSPersistentCloudKitContainer`; if your stack uses a plain `NSPersistentContainer`, the monitor will remain in `.idle` indefinitely
- CloudKit requires a valid iCloud account on the device and a correctly provisioned container in App Store Connect
- The monitor must be kept alive for the duration of the session; releasing it removes the observer and stops all updates

## Contributing

Contributions are welcome. Please open an Issue or PR for fixes, feature proposals, or documentation improvements.

PR titles should follow the format: `YYYY-mm-dd - Title`

## Licence

`CloudSyncKit` is released under the MIT licence.
