//
//  ContentView.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import SwiftUI
import SwiftData
import ShoppingListFeature

/**
 * Example of how to use the ShoppingListFeature package in your app.
 * 
 * This ContentView demonstrates the super simple integration pattern.
 * All the shopping list logic has been moved to the package.
 */

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        // Super simple integration - just one line!
        // This replaces the original 200+ lines of shopping list logic
        ShoppingListFeatureModule.createView(modelContext: modelContext)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
