//
//  Item.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
