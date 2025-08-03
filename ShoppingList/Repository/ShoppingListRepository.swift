//
//  ShoppingListRepository.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import SwiftData
import Combine

/**
 * Protocol defining the data access layer for shopping list items.
 * 
 * This protocol abstracts the data persistence operations, allowing for easy testing
 * and potential future implementations with different data sources (local, remote, etc.).
 */
protocol ShoppingListRepositoryProtocol {
    /**
     * Fetches all shopping list items from the data store.
     * 
     * - Returns: An array of all shopping items, sorted by creation date (newest first)
     * - Throws: An error if the fetch operation fails
     */
    func fetchItems() async throws -> [Item]
    
    /**
     * Adds a new shopping item to the data store.
     * 
     * - Parameters:
     *   - name: The name/title of the item (required)
     *   - quantity: The quantity to purchase (required)
     *   - note: Optional notes or additional information about the item
     * - Throws: An error if the save operation fails
     */
    func addItem(name: String, quantity: Int, note: String?) async throws
    
    /**
     * Updates an existing shopping item with new values.
     * 
     * - Parameters:
     *   - item: The item to update
     *   - name: New name for the item
     *   - quantity: New quantity for the item
     *   - note: New optional note for the item
     * - Throws: An error if the update operation fails
     */
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws
    
    /**
     * Deletes a shopping item from the data store.
     * 
     * - Parameters:
     *   - item: The item to delete
     * - Throws: An error if the delete operation fails
     */
    func deleteItem(_ item: Item) async throws
    
    /**
     * Toggles the purchase status of a shopping item.
     * 
     * - Parameters:
     *   - item: The item whose purchase status should be toggled
     * - Throws: An error if the update operation fails
     */
    func toggleBoughtStatus(for item: Item) async throws
}

/**
 * Defines the available sorting options for shopping list items.
 */
enum SortOrder {
    /// Sort items by creation date, oldest first
    case createdAtAscending
    /// Sort items by creation date, newest first
    case createdAtDescending
    /// Sort items by last update date, oldest first
    case updatedAtAscending
    /// Sort items by last update date, newest first
    case updatedAtDescending
}

/**
 * SwiftData implementation of the shopping list repository.
 * 
 * This class provides data persistence using SwiftData and integrates with
 * the sync service for background synchronization.
 */
class ShoppingListRepository: ShoppingListRepositoryProtocol {
    /// SwiftData model context for database operations
    private let modelContext: ModelContext
    
    /// Optional sync service for background synchronization
    private var syncService: SyncServiceProtocol?
    
    /// Combine cancellables for managing subscriptions (legacy, not used in current implementation)
    private var cancellables = Set<AnyCancellable>()
    
    /**
     * Initializes the repository with a SwiftData model context.
     * 
     * - Parameters:
     *   - modelContext: The SwiftData model context for database operations
     *   - syncService: Optional sync service for background synchronization
     */
    init(modelContext: ModelContext, syncService: SyncServiceProtocol? = nil) {
        self.modelContext = modelContext
        self.syncService = syncService
    }
    
    /**
     * Sets the sync service for background synchronization.
     * 
     * - Parameters:
     *   - syncService: The sync service to use for background operations
     */
    func setSyncService(_ syncService: SyncServiceProtocol) {
        self.syncService = syncService
    }
    
    func fetchItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func addItem(name: String, quantity: Int, note: String?) async throws {
        let newItem = Item(name: name, quantity: quantity, note: note)
        modelContext.insert(newItem)
        
        try modelContext.save()
        
        // Trigger background sync after local change
        if let syncService = syncService {
            Task {
                try? await syncService.performBackgroundSync()
            }
        }
    }
    
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws {
        item.update(name: name, quantity: quantity, note: note)
        
        try modelContext.save()
        
        // Trigger background sync after local change
        if let syncService = syncService {
            Task {
                try? await syncService.performBackgroundSync()
            }
        }
    }
    
    func deleteItem(_ item: Item) async throws {
        modelContext.delete(item)
        
        try modelContext.save()
        
        // Trigger background sync after local change
        if let syncService = syncService {
            Task {
                try? await syncService.performBackgroundSync()
            }
        }
    }
    
    func toggleBoughtStatus(for item: Item) async throws {
        if item.isBought {
            item.markAsNotBought()
        } else {
            item.markAsBought()
        }
        
        try modelContext.save()
        
        // Trigger background sync after local change
        if let syncService = syncService {
            Task {
                try? await syncService.performBackgroundSync()
            }
        }
    }
}
