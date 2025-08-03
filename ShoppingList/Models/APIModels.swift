//
//  APIModels.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation

// MARK: - API Models

/**
 * Represents a shopping list item as it appears on the remote server.
 * 
 * This struct is used for serialization/deserialization when communicating
 * with the remote API and contains all the necessary fields for synchronization.
 */
struct RemoteItem: Codable {
    /// Unique identifier for the item on the remote server
    let id: String
    
    /// The name/title of the shopping item
    let name: String
    
    /// The quantity of the item to purchase
    let quantity: Int
    
    /// Optional notes or additional information about the item
    let note: String?
    
    /// Whether the item has been purchased/marked as bought
    let isBought: Bool
    
    /// Timestamp when the item was first created
    let createdAt: Date
    
    /// Timestamp when the item was last modified
    let updatedAt: Date
    
    /**
     * Initializes a RemoteItem with all required properties.
     * 
     * - Parameters:
     *   - id: Unique identifier for the item
     *   - name: The name/title of the item
     *   - quantity: The quantity to purchase
     *   - note: Optional notes about the item
     *   - isBought: Whether the item has been purchased
     *   - createdAt: Timestamp when the item was created
     *   - updatedAt: Timestamp when the item was last modified
     */
    init(
        id: String,
        name: String,
        quantity: Int,
        note: String?,
        isBought: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = isBought
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /**
     * Initializes a RemoteItem from a local Item model.
     * 
     * Converts a local SwiftData Item to a RemoteItem for API communication.
     * - Parameters:
     *   - localItem: The local Item model to convert
     */
    init(from localItem: Item) {
        self.id = localItem.syncId
        self.name = localItem.name
        self.quantity = localItem.quantity
        self.note = localItem.note
        self.isBought = localItem.isBought
        self.createdAt = localItem.createdAt
        self.updatedAt = localItem.updatedAt
    }
}

/**
 * Response structure for fetch operations from the remote server.
 * 
 * Contains the remote items and metadata about the synchronization state.
 */
struct SyncResponse: Codable {
    /// Array of shopping list items from the remote server
    let items: [RemoteItem]
    
    /// Timestamp of the last successful synchronization
    let lastSyncTimestamp: Date
}

/**
 * Request structure for upload operations to the remote server.
 * 
 * Contains local items to be uploaded and metadata for conflict resolution.
 */
struct SyncRequest: Codable {
    /// Array of local shopping list items to upload
    let items: [RemoteItem]
    
    /// Timestamp of the last successful synchronization for conflict resolution
    let lastSyncTimestamp: Date
} 
