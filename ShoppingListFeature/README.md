# ShoppingListFeature

A modular Swift Package providing a complete shopping list feature for super-app integration. Built with SwiftData, SwiftUI, and offline-first architecture.

## Features

- ✅ **Complete Shopping List**: Add, edit, delete, mark as bought
- ✅ **Search & Filter**: Search by name/notes, filter by status
- ✅ **Sorting**: By creation or update date
- ✅ **Offline-First**: SwiftData persistence, works without internet
- ✅ **Sync Ready**: Optional background synchronization
- ✅ **Simple Integration**: One-line integration into any SwiftUI app

## Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 15.0+

## Quick Integration

```swift
import SwiftUI
import SwiftData
import ShoppingListFeature

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        // One line integration!
        ShoppingListFeatureModule.createView(modelContext: modelContext)
    }
}
```

## With Sync (Optional)

```swift
ShoppingListFeatureModule.createView(
    modelContext: modelContext,
    enableSync: true
)
```

## Architecture

- **MVVM Pattern**: Clean separation of concerns
- **SwiftData**: Local persistence with `@Model`
- **Repository Pattern**: Abstracted data access
- **Dependency Injection**: Customizable services
- **Background Tasks**: iOS background sync support

## Testing

The package includes comprehensive unit and UI tests using XCTest.

## Background Tasks Setup

Add to Info.plist for background sync:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.shoppinglist.sync</string>
</array>
```
