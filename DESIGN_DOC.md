# Shopping List - Design Document

## Architecture Decisions

### 1. Simplified MVVM with Repository Pattern

**Decision**: Implemented a simplified MVVM (Model-View-ViewModel) with Repository pattern for clean separation of concerns without over-engineering.

**Rationale**:
- **Simplicity**: Business logic in ViewModel for easy understanding and maintenance
- **Testability**: MVVM allows easy unit testing of business logic in ViewModels
- **Maintainability**: Clear separation between UI, business logic, and data access
- **Scalability**: Repository pattern enables future sync capabilities without UI changes
- **SwiftUI Integration**: MVVM works naturally with SwiftUI's reactive programming model

**Implementation**:
- `Item` (Model): SwiftData entity with business methods
- `ShoppingListViewModel` (ViewModel): Handles UI state and business logic directly
- `ContentView`, `ShoppingItemRow`, `AddEditItemView` (Views): Pure UI components
- `ShoppingListRepository` (Repository): Abstracts data access layer

### 2. SwiftData for Local Persistence

**Decision**: Used SwiftData over Core Data or Realm for local persistence.

**Rationale**:
- **iOS 17+**: Leverages latest Apple framework with modern Swift syntax
- **SwiftUI Integration**: Native integration with SwiftUI's `@Query` and `@Environment`
- **Performance**: Optimized for iOS with automatic background processing
- **Simplicity**: Less boilerplate compared to Core Data
- **Future-proof**: Apple's strategic direction for data persistence

### 3. Async/Await for Modern Concurrency

**Decision**: Used async/await over Combine for modern, readable asynchronous operations.

**Rationale**:
- **Modern Swift**: Leverages latest Swift concurrency features
- **Readability**: More straightforward than Combine publishers
- **Error Handling**: Natural try-catch error handling
- **Performance**: Efficient concurrency without Combine overhead
- **Testing**: Easier to test with async/await patterns

### 4. Manual Dependency Injection

**Decision**: Implemented manual dependency injection over complex DI containers.

**Rationale**:
- **Simplicity**: No external dependencies for DI container
- **Transparency**: Clear dependency flow visible in code
- **Performance**: No runtime overhead of reflection-based DI
- **Control**: Explicit control over object lifecycle
- **Testing**: Easy to inject mocks for testing

### 5. Offline-First Architecture with Sync

**Decision**: Designed for offline-first operation with background sync capabilities.

**Rationale**:
- **User Experience**: App works immediately without network
- **Reliability**: No dependency on network connectivity
- **Performance**: Fast local operations
- **Background Sync**: Automatic sync when network available
- **Data Integrity**: Local persistence ensures data safety

## Rejected Alternatives

### 1. Complex Clean Architecture vs Simplified MVVM

**Rejected**: Full Clean Architecture with Use Cases, Domain Services, and complex state management

**Reasoning**:
- **Over-engineering**: Too many layers for a shopping list feature
- **Complexity**: Excessive abstraction for the problem domain
- **Maintenance**: Higher development and maintenance cost
- **Team Size**: Better suited for large teams and complex features

**Trade-offs**:
- ✅ Better separation of concerns for complex features
- ✅ More testable individual components
- ❌ Overkill for shopping list functionality
- ❌ Higher complexity and learning curve
- ❌ Slower development velocity

### 2. Core Data vs SwiftData

**Rejected**: Core Data with manual NSManagedObjectContext management

**Reasoning**:
- **Complexity**: More boilerplate code and manual context management
- **SwiftUI Integration**: Requires additional wrappers for SwiftUI integration
- **Learning Curve**: More complex API compared to SwiftData
- **Future Direction**: Apple is investing in SwiftData as the future

**Trade-offs**:
- ✅ More mature ecosystem and community support
- ❌ Higher complexity and maintenance overhead
- ❌ Less native SwiftUI integration

### 3. Combine vs Async/Await

**Rejected**: Combine framework for reactive programming

**Reasoning**:
- **Complexity**: More complex than async/await for simple operations
- **Learning Curve**: Steeper learning curve for developers
- **Overhead**: Additional framework overhead for simple async operations
- **Modern Swift**: Async/await is the future direction for Swift concurrency

**Trade-offs**:
- ✅ Better for complex reactive data flows
- ✅ Native SwiftUI integration
- ❌ Overkill for simple CRUD operations
- ❌ More complex error handling
- ❌ Additional framework dependency

## Technical Implementation Details

### Data Flow Architecture

```
User Action → View → ViewModel → Repository → SwiftData
                ↑                                    ↓
                ←────────── Async/Await ←─────────────
```

### Error Handling Strategy

- **Repository Level**: Returns `async throws` for error propagation
- **ViewModel Level**: Catches errors and updates UI state
- **View Level**: Displays alerts for user-facing errors
- **Graceful Degradation**: App continues working on local errors

### Performance Considerations

- **Debounced Search**: 300ms delay to prevent excessive queries
- **Lazy Loading**: SwiftData handles pagination automatically
- **Memory Management**: Efficient async/await without subscription overhead
- **UI Updates**: MainActor ensures UI updates on main thread

### Testing Strategy

- **Unit Tests**: ViewModel business logic with mock repository
- **UI Tests**: End-to-end user workflows
- **Mock Repository**: In-memory implementation for testing
- **Test Coverage**: Core functionality and edge cases

## Current Architecture Summary

### Core Components

#### 1. Models
- **`Item`**: SwiftData model with business methods for shopping list items
- **`RemoteItem`**: API model for server communication
- **`SyncRequest/Response`**: Data structures for synchronization

#### 2. Repository Layer
- **`ShoppingListRepositoryProtocol`**: Abstract data access interface
- **`ShoppingListRepository`**: SwiftData implementation with sync integration

#### 3. Services
- **`NetworkServiceProtocol`**: HTTP operations for remote data
- **`SyncServiceProtocol`**: Synchronization between local and remote data
- **`BackgroundTaskServiceProtocol`**: iOS background processing

#### 4. ViewModel
- **`ShoppingListViewModel`**: Business logic and UI state management
- **Direct repository integration**: Simple, testable architecture

#### 5. Views
- **`ContentView`**: Main shopping list interface
- **`AddEditItemView`**: Item creation and editing
- **`ShoppingItemRow`**: Individual item display

### Data Flow

```
User Action → View → ViewModel → Repository → SwiftData
                ↑                                    ↓
                ←────────── Async/Await ←─────────────
```

### Error Handling

- **Network Errors**: Structured `NetworkError` enum with localized descriptions
- **Repository Errors**: Standard Swift errors with async/await propagation
- **UI Error Display**: User-friendly error messages in alerts

### Testing Strategy

- **Unit Tests**: ViewModel with mock repository
- **UI Tests**: End-to-end user workflows
- **Mock Services**: In-memory implementations for testing

## Future Architecture Considerations

### Enhanced Sync Implementation

```swift
// Enhanced sync service with conflict resolution
protocol SyncServiceProtocol {
    func syncItems() async throws
    func resolveConflicts(_ items: [Item]) async throws -> [Item]
    func retryWithBackoff() async throws
}

class EnhancedSyncService: SyncServiceProtocol {
    // Implementation with exponential backoff
    // Advanced conflict resolution strategies
    // Real-time sync capabilities
}
```

### Modular Packaging

The current architecture supports easy extraction into:
- **Swift Package**: For distribution as a module
- **Framework**: For integration into larger apps
- **Standalone App**: Current implementation

### Scalability Considerations

- **Multiple Lists**: Repository pattern supports multiple shopping lists
- **User Management**: Easy to add user authentication layer
- **Sharing**: Repository can be extended for collaborative features
- **Analytics**: Clean separation enables analytics integration
- **Offline Support**: Robust offline-first architecture 