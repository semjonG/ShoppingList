# Shopping List - iOS Engineer Code Challenge

A modular Shopping List feature built with SwiftUI, SwiftData, and MVVM architecture designed to integrate into a larger super-app.

## 🚀 Features

### Core Functionality
- ✅ Add, edit, and delete shopping items
- ✅ Mark items as "bought" with visual feedback
- ✅ Filter to show/hide bought items
- ✅ Search by item name or notes
- ✅ Sort by creation or modification date (ascending/descending)

### Item Properties
- **Name** (required) - Item name
- **Quantity** (required) - Number of items needed
- **Note** (optional) - Additional information
- **Bought Status** - Toggle between bought/not bought
- **Timestamps** - Creation and modification dates for sync

### Technical Features
- 📱 **Offline-first** - Works completely offline
- 💾 **Local Persistence** - SwiftData for local storage
- 🔄 **Background Sync Ready** - Architecture supports remote sync
- 🏗 **Clean Architecture** - MVVM with Repository pattern
- 🧪 **Comprehensive Testing** - Unit and UI tests included

## 🛠 Technology Stack

- **iOS Target**: iOS 17.0+
- **UI Framework**: SwiftUI
- **Data Persistence**: SwiftData
- **Architecture**: MVVM with Repository Pattern
- **Testing**: XCTest (Unit & UI Tests)
- **Dependency Management**: Manual Injection

## 📦 Project Structure

```
ShoppingList/
├── ShoppingList/
│   ├── Models/
│   │   └── Item.swift                 # SwiftData model
│   ├── Repository/
│   │   └── ShoppingListRepository.swift # Data access layer
│   ├── ViewModel/
│   │   └── ShoppingListViewModel.swift # Business logic
│   ├── Views/
│   │   ├── ShoppingItemRow.swift      # Item row component
│   │   └── AddEditItemView.swift      # Add/edit form
│   ├── ContentView.swift              # Main view
│   └── ShoppingListApp.swift          # App entry point
├── ShoppingListTests/
│   └── ShoppingListViewModelTests.swift # Unit tests
└── ShoppingListUITests/
    └── ShoppingListUITests.swift      # UI tests
```

## 🚀 Build and Run Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- macOS 14.0+ (for development)

### Steps
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ShoppingList
   ```

2. **Open in Xcode**
   ```bash
   open ShoppingList.xcodeproj
   ```

3. **Select target device**
   - Choose iOS Simulator (iPhone 15 Pro recommended)
   - Or connect physical iOS device

4. **Build and run**
   - Press `Cmd + R` or click the Play button
   - App will launch with empty shopping list

### Running Tests
- **Unit Tests**: `Cmd + U` or Product → Test
- **UI Tests**: Select ShoppingListUITests scheme and run

## 🧪 Testing

### Unit Tests
- **ViewModel Tests**: Business logic validation
- **Repository Tests**: Data operations
- **Model Tests**: SwiftData model behavior

### UI Tests
- **Add Item Flow**: Complete item creation
- **Edit Item Flow**: Modify existing items
- **Delete Item Flow**: Remove items
- **Search & Filter**: Test search and filter functionality
- **Bought Status**: Toggle bought/not bought

## 🏗 Architecture Overview

### MVVM Pattern
- **Model**: SwiftData `Item` entity
- **View**: SwiftUI views (`ContentView`, `ShoppingItemRow`, etc.)
- **ViewModel**: `ShoppingListViewModel` with business logic

### Repository Pattern
- **Interface**: `ShoppingListRepositoryProtocol`
- **Implementation**: `ShoppingListRepository`
- **Benefits**: Testability, abstraction, future sync support

### Dependency Injection
- Manual injection through initializers
- Repository injected into ViewModel
- ModelContext injected into Repository

## 🔄 Future Enhancements

### Background Sync
- REST API integration
- Last-write-wins conflict resolution
- BackgroundTasks framework
- Exponential backoff retry logic

### Additional Features
- Categories/tags for items
- Shopping list sharing
- Barcode scanning
- Voice input
- Widget support

## 📱 Screenshots

*Screenshots would be added here showing the app in action*

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is part of an iOS Engineer Code Challenge.

## 🛠 AI Tools Used

- **Cursor IDE**: Primary development environment
- **GitHub Copilot**: Code suggestions and completions
- **ChatGPT**: Architecture discussions and problem solving

## 📞 Support

For questions or issues, please contact the development team. 