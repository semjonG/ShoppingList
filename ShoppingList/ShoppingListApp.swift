//
//  ShoppingListApp.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import SwiftUI
import SwiftData

@main
struct ShoppingListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Item.self, inMemory: true)
    }
}
