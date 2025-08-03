//
//  ShoppingListViewModelTests.swift
//  ShoppingListFeatureTests
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import XCTest
import SwiftData
@testable import ShoppingListFeature

final class ShoppingListViewModelTests: XCTestCase {
    var viewModel: ShoppingListViewModel!
    var mockRepository: MockShoppingListRepository!
    
    override func setUp() {
        super.setUp()
        // Note: setUp() runs on main thread by default in XCTest
        mockRepository = MockShoppingListRepository()
        viewModel = ShoppingListViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    @MainActor
    func testAddItemSuccess() async throws {
        // Given
        let itemName = "Milk"
        let quantity = 2
        let note = "Organic"
        
        // When
        await viewModel.addItem(name: itemName, quantity: quantity, note: note)
        
        // Then
        XCTAssertFalse(viewModel.showingAddItem)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testAddItemWithEmptyName() async throws {
        // Given
        
        // When
        await viewModel.addItem(name: "", quantity: 1, note: nil)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Item name cannot be empty")
    }
    
    @MainActor
    func testAddItemWithZeroQuantity() async throws {
        // Given
        
        // When
        await viewModel.addItem(name: "Milk", quantity: 0, note: nil)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Quantity must be greater than 0")
    }
    
    @MainActor
    func testToggleBoughtStatus() async throws {
        // Given
        let item = Item(name: "Milk", quantity: 1)
        
        // When
        await viewModel.toggleBoughtStatus(for: item)
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testFilterItems() async throws {
        // Given
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2)
        ]
        mockRepository.mockItems = items
        
        // When
        viewModel.showBoughtItems = false
        await viewModel.loadItems()
        
        // Then
        XCTAssertEqual(viewModel.filteredItems.count, 2)
        XCTAssertTrue(viewModel.filteredItems.contains { $0.name == "Milk" })
        XCTAssertTrue(viewModel.filteredItems.contains { $0.name == "Bread" })
    }
    
    @MainActor
    func testSearchItems() async throws {
        // Given
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2),
            Item(name: "Apple", quantity: 3)
        ]
        mockRepository.mockItems = items
        await viewModel.loadItems()
        
        // When
        viewModel.searchTextChanged("Milk")
        
        // Then
        XCTAssertEqual(viewModel.filteredItems.count, 1)
        XCTAssertEqual(viewModel.filteredItems.first?.name, "Milk")
    }
    
    @MainActor
    func testSortItems() async throws {
        // Given
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2)
        ]
        mockRepository.mockItems = items
        await viewModel.loadItems()
        
        // When
        viewModel.sortOrderChanged(.createdAtAscending)
        
        // Then
        XCTAssertEqual(viewModel.sortOrder, .createdAtAscending)
    }
    
    @MainActor
    func testClearError() async throws {
        // Given
        viewModel.errorMessage = "Test error"
        
        // When
        viewModel.clearError()
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadItems() async throws {
        // Given
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2)
        ]
        mockRepository.mockItems = items
        
        // When
        await viewModel.loadItems()
        
        // Then
        XCTAssertEqual(viewModel.items.count, 2)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testLoadItemsError() async throws {
        // Given
        mockRepository.shouldThrowError = true
        
        // When
        await viewModel.loadItems()
        
        // Then
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    @MainActor
    func testDeleteItem() async throws {
        // Given
        let item = Item(name: "Milk", quantity: 1)
        mockRepository.mockItems = [item]
        await viewModel.loadItems()
        
        // When
        await viewModel.deleteItem(item)
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testUpdateItem() async throws {
        // Given
        let item = Item(name: "Milk", quantity: 1)
        
        // When
        await viewModel.updateItem(item, name: "Organic Milk", quantity: 2, note: "Fresh")
        
        // Then
        XCTAssertNil(viewModel.errorMessage)
    }
    
    @MainActor
    func testUpdateItemWithEmptyName() async throws {
        // Given
        let item = Item(name: "Milk", quantity: 1)
        
        // When
        await viewModel.updateItem(item, name: "", quantity: 2, note: nil)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Item name cannot be empty")
    }
    
    @MainActor
    func testUpdateItemWithZeroQuantity() async throws {
        // Given
        let item = Item(name: "Milk", quantity: 1)
        
        // When
        await viewModel.updateItem(item, name: "Milk", quantity: 0, note: nil)
        
        // Then
        XCTAssertEqual(viewModel.errorMessage, "Quantity must be greater than 0")
    }
    

    
    @MainActor
    func testInitialSync() async throws {
        // Given
        let mockSyncService = MockSyncService()
        viewModel = ShoppingListViewModel(repository: mockRepository, syncService: mockSyncService)
        
        // When
        await viewModel.loadItems()
        
        // Then
        XCTAssertNil(viewModel.syncError)
    }
} 
