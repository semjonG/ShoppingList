//
//  MockShoppingListRepository.swift
//  ShoppingListFeatureTests
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
@testable import ShoppingListFeature

@MainActor
class MockShoppingListRepository: ShoppingListRepositoryProtocol {
    var mockItems: [Item] = []
    var shouldThrowError = false
    var lastError: Error = NSError(domain: "Test", code: 0)
    
    func fetchItems() async throws -> [Item] {
        if shouldThrowError {
            throw lastError
        }
        return mockItems
    }
    
    func addItem(name: String, quantity: Int, note: String?) async throws {
        if shouldThrowError {
            throw lastError
        }
        
        let newItem = Item(name: name, quantity: quantity, note: note)
        mockItems.append(newItem)
    }
    
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws {
        if shouldThrowError {
            throw lastError
        }
        
        if let index = mockItems.firstIndex(where: { $0.syncId == item.syncId }) {
            mockItems[index].update(name: name, quantity: quantity, note: note)
        }
    }
    
    func deleteItem(_ item: Item) async throws {
        if shouldThrowError {
            throw lastError
        }
        
        mockItems.removeAll { $0.syncId == item.syncId }
    }
    
    func toggleBoughtStatus(for item: Item) async throws {
        if shouldThrowError {
            throw lastError
        }
        
        if let index = mockItems.firstIndex(where: { $0.syncId == item.syncId }) {
            if mockItems[index].isBought {
                mockItems[index].markAsNotBought()
            } else {
                mockItems[index].markAsBought()
            }
        }
    }
} 