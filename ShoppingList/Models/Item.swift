//
//  Item.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import SwiftData

/**
 * Shopping list item model representing a single item in the shopping list.
 * 
 * This SwiftData model contains all the necessary information for a shopping item
 * including its name, quantity, optional notes, purchase status, and metadata
 * for synchronization and tracking purposes.
 */
@Model
final class Item {
    /// The name/title of the shopping item (required)
    var name: String
    
    /// The quantity of the item to purchase (required)
    var quantity: Int
    
    /// Optional notes or additional information about the item
    var note: String?
    
    /// Whether the item has been purchased/marked as bought
    var isBought: Bool
    
    /// Timestamp when the item was first created
    var createdAt: Date
    
    /// Timestamp when the item was last modified
    var updatedAt: Date
    
    /// Unique identifier for synchronization with remote server
    var syncId: String
    
    /**
     * Initializes a new shopping item with the specified properties.
     * 
     * - Parameters:
     *   - name: The name/title of the item (required)
     *   - quantity: The quantity to purchase (required)
     *   - note: Optional notes or additional information about the item
     */
    init(
        name: String,
        quantity: Int,
        note: String? = nil
    ) {
        self.name = name
        self.quantity = quantity
        self.note = note
        self.isBought = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.syncId = UUID().uuidString
    }
    
    /**
     * Marks the item as purchased/bought.
     * Updates the purchase status and modification timestamp.
     */
    func markAsBought() {
        isBought = true
        updatedAt = Date()
    }
    
    /**
     * Marks the item as not purchased/not bought.
     * Updates the purchase status and modification timestamp.
     */
    func markAsNotBought() {
        isBought = false
        updatedAt = Date()
    }
    
    /**
     * Updates the item's properties with new values.
     * 
     * - Parameters:
     *   - name: New name for the item
     *   - quantity: New quantity for the item
     *   - note: New optional note for the item
     */
    func update(name: String, quantity: Int, note: String?) {
        self.name = name
        self.quantity = quantity
        self.note = note
        self.updatedAt = Date()
    }
} 
