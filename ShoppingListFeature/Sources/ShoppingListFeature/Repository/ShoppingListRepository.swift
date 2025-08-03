import Foundation
import SwiftData
import Combine

// MARK: - Repository Protocol

/**
 * Protocol defining the interface for shopping list data operations.
 *
 * This protocol abstracts the data persistence operations, allowing for easy testing
 * and potential future implementations with different data sources (local, remote, etc.).
 */
public protocol ShoppingListRepositoryProtocol {
    /**
     * Fetches all shopping list items from the data store.
     *
     * - Returns: An array of all shopping items, sorted by creation date (newest first)
     * - Throws: An error if the fetch operation fails
     */
    @MainActor
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
    @MainActor
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
    @MainActor
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws
    
    /**
     * Deletes a shopping item from the data store.
     *
     * - Parameters:
     *   - item: The item to delete
     * - Throws: An error if the delete operation fails
     */
    @MainActor
    func deleteItem(_ item: Item) async throws
    
    /**
     * Toggles the purchase status of a shopping item.
     *
     * - Parameters:
     *   - item: The item whose purchase status should be toggled
     * - Throws: An error if the update operation fails
     */
    @MainActor
    func toggleBoughtStatus(for item: Item) async throws
}

// MARK: - Sort Order Enum

/**
 * Defines the available sorting options for shopping list items.
 */
public enum SortOrder {
    /// Sort items by creation date, oldest first
    case createdAtAscending
    /// Sort items by creation date, newest first
    case createdAtDescending
    /// Sort items by last update date, oldest first
    case updatedAtAscending
    /// Sort items by last update date, newest first
    case updatedAtDescending
}

// MARK: - Repository
/**
 * SwiftData implementation of the shopping list repository.
 * 
 * This class provides data persistence using SwiftData and integrates with
 * the sync service for background synchronization.
 */
public class ShoppingListRepository: ShoppingListRepositoryProtocol {
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
    public init(modelContext: ModelContext, syncService: SyncServiceProtocol? = nil) {
        self.modelContext = modelContext
        self.syncService = syncService
    }
    
    /**
     * Sets the sync service for background synchronization.
     * 
     * - Parameters:
     *   - syncService: The sync service to use for background operations
     */
    public func setSyncService(_ syncService: SyncServiceProtocol) {
        self.syncService = syncService
    }
    
    @MainActor
    public func fetchItems() async throws -> [Item] {
        let descriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    @MainActor
    public func addItem(name: String, quantity: Int, note: String?) async throws {
        let newItem = Item(name: name, quantity: quantity, note: note)
        modelContext.insert(newItem)
        
        try modelContext.save()
    }
    
    @MainActor
    public func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async throws {
        item.update(name: name, quantity: quantity, note: note)
        
        try modelContext.save()
    }
    
    @MainActor
    public func deleteItem(_ item: Item) async throws {
        modelContext.delete(item)
        
        try modelContext.save()
    }
    
    @MainActor
    public func toggleBoughtStatus(for item: Item) async throws {
        if item.isBought {
            item.markAsNotBought()
        } else {
            item.markAsBought()
        }
        
        try modelContext.save()
    }
} 
