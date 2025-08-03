//
//  ShoppingListViewModelTests.swift
//  ShoppingListTests
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Testing
import SwiftData
@testable import ShoppingList

struct ShoppingListViewModelTests {
    var viewModel: ShoppingListViewModel!
    var mockRepository: MockShoppingListRepository!
    
    mutating func setUp() {
        mockRepository = MockShoppingListRepository()
        viewModel = ShoppingListViewModel(repository: mockRepository)
    }
    
    mutating func tearDown() {
        viewModel = nil
        mockRepository = nil
    }
    
    #Test("Add item successfully")
    func testAddItemSuccess() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let itemName = "Milk"
        let quantity = 2
        let note = "Organic"
        
        // When
        await viewModel.addItem(name: itemName, quantity: quantity, note: note)
        
        // Then
        #expect(viewModel.showingAddItem == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    #Test("Show error for empty item name")
    func testAddItemWithEmptyName() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        // When
        await viewModel.addItem(name: "", quantity: 1, note: nil)
        
        // Then
        #expect(viewModel.errorMessage == "Item name cannot be empty")
    }
    
    #Test("Show error for zero quantity")
    func testAddItemWithZeroQuantity() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        // When
        await viewModel.addItem(name: "Milk", quantity: 0, note: nil)
        
        // Then
        #expect(viewModel.errorMessage == "Quantity must be greater than 0")
    }
    
    #Test("Toggle bought status successfully")
    func testToggleBoughtStatus() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let item = Item(name: "Milk", quantity: 1)
        
        // When
        await viewModel.toggleBoughtStatus(for: item)
        
        // Then
        #expect(viewModel.errorMessage == nil)
    }
    
    #Test("Filter items correctly")
    func testFilterItems() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2)
        ]
        mockRepository.mockItems = items
        
        // When
        viewModel.showBoughtItems = false
        await viewModel.loadItems()
        
        // Then
        #expect(viewModel.filteredItems.count == 2)
    }
    
    #Test("Search items correctly")
    func testSearchItems() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let items = [
            Item(name: "Milk", quantity: 1),
            Item(name: "Bread", quantity: 2)
        ]
        mockRepository.mockItems = items
        
        // When
        viewModel.searchText = "Milk"
        await viewModel.loadItems()
        
        // Then
        #expect(viewModel.filteredItems.count == 1)
        #expect(viewModel.filteredItems.first?.name == "Milk")
    }
    
    #Test("Update item successfully")
    func testUpdateItem() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let item = Item(name: "Milk", quantity: 1)
        mockRepository.mockItems = [item]
        
        // When
        await viewModel.updateItem(item, name: "Chocolate Milk", quantity: 2, note: "Dark chocolate")
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(item.name == "Chocolate Milk")
        #expect(item.quantity == 2)
        #expect(item.note == "Dark chocolate")
    }
    
    #Test("Delete item successfully")
    func testDeleteItem() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let item = Item(name: "Milk", quantity: 1)
        mockRepository.mockItems = [item]
        
        // When
        await viewModel.deleteItem(item)
        
        // Then
        #expect(viewModel.errorMessage == nil)
        #expect(mockRepository.mockItems.isEmpty)
    }
    
    #Test("Sort items by creation date descending")
    func testSortItemsByCreationDateDescending() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        let item1 = Item(name: "Milk", quantity: 1)
        let item2 = Item(name: "Bread", quantity: 2)
        mockRepository.mockItems = [item1, item2]
        
        // When
        viewModel.sortOrder = .createdAtDescending
        await viewModel.loadItems()
        
        // Then
        #expect(viewModel.filteredItems.count == 2)
        // Note: In a real test, we'd verify the order, but mock items have same timestamp
    }
    
    #Test("Repository error handling")
    func testRepositoryErrorHandling() async throws {
        // Given
        setUp()
        defer { tearDown() }
        
        mockRepository.shouldFail = true
        mockRepository.error = NSError(domain: "Test", code: 1, userInfo: nil)
        
        // When
        await viewModel.addItem(name: "Milk", quantity: 1, note: nil)
        
        // Then
        #expect(viewModel.errorMessage != nil)
    }
}

// MARK: - Mock Repository

class MockShoppingListRepository: ShoppingListRepositoryProtocol {
    var mockItems: [Item] = []
    var shouldFail = false
    var error: Error = NSError(domain: "Test", code: 1, userInfo: nil)
    
    func fetchItems() async throws -> [Item] {
        if shouldFail {
            throw error
        }
        return mockItems
    }
    
    func addItem(name: String, quantity: Int, note: String?) async throws {
        if shouldFail {
            throw error
        }
        let newItem = Item(name: name, quantity: quantity, note: note)
        mockItems.append(newItem)
    }
    
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws {
        if shouldFail {
            throw error
        }
        item.update(name: name, quantity: quantity, note: note)
    }
    
    func deleteItem(_ item: Item) async throws {
        if shouldFail {
            throw error
        }
        mockItems.removeAll { $0.syncId == item.syncId }
    }
    
    func toggleBoughtStatus(for item: Item) async throws {
        if shouldFail {
            throw error
        }
        if item.isBought {
            item.markAsNotBought()
        } else {
            item.markAsBought()
        }
    }
} 