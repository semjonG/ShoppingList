//
//  ShoppingListViewModel.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import SwiftUI

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var filteredItems: [Item] = []
    @Published var searchText = ""
    @Published var showBoughtItems = false
    @Published var sortOrder: SortOrder = .createdAtDescending
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingAddItem = false
    @Published var editingItem: Item?
    @Published var isSyncing = false
    @Published var syncError: String?
    
    private var repository: ShoppingListRepositoryProtocol
    private let syncService: SyncServiceProtocol?
    
    init(repository: ShoppingListRepositoryProtocol, syncService: SyncServiceProtocol? = nil) {
        self.repository = repository
        self.syncService = syncService
        
        // Start async operations
        Task { @MainActor in
            await loadItems()
            await performInitialSync()
        }
    }
    

    
    private func applyFiltersAndSort() {
        var filteredItems = self.items
        
        // Apply bought filter
        if !showBoughtItems {
            filteredItems = filteredItems.filter { !$0.isBought }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filteredItems = filteredItems.filter { item in
                item.name.localizedStandardContains(searchText) ||
                (item.note?.localizedStandardContains(searchText) ?? false)
            }
        }
        
        // Apply sorting
        switch sortOrder {
        case .createdAtAscending:
            filteredItems.sort { $0.createdAt < $1.createdAt }
        case .createdAtDescending:
            filteredItems.sort { $0.createdAt > $1.createdAt }
        case .updatedAtAscending:
            filteredItems.sort { $0.updatedAt < $1.updatedAt }
        case .updatedAtDescending:
            filteredItems.sort { $0.updatedAt > $1.updatedAt }
        }
        
        self.filteredItems = filteredItems
    }
    
    @MainActor
    func loadItems() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let items = try await repository.fetchItems()
            self.items = items
            self.applyFiltersAndSort()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        self.isLoading = false
    }
    
    @MainActor
    func addItem(name: String, quantity: Int, note: String?) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Item name cannot be empty"
            return
        }
        
        guard quantity > 0 else {
            errorMessage = "Quantity must be greater than 0"
            return
        }
        
        do {
            try await repository.addItem(name: name, quantity: quantity, note: note)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Item name cannot be empty"
            return
        }
        
        guard quantity > 0 else {
            errorMessage = "Quantity must be greater than 0"
            return
        }
        
        do {
            try await repository.updateItem(item, name: name, quantity: quantity, note: note)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func deleteItem(_ item: Item) async {
        do {
            try await repository.deleteItem(item)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func toggleBoughtStatus(for item: Item) async {
        do {
            try await repository.toggleBoughtStatus(for: item)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Debounced Input Handlers
    
    func searchTextChanged(_ text: String) {
        searchText = text
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            applyFiltersAndSort()
        }
    }
    
    func showBoughtItemsChanged(_ show: Bool) {
        showBoughtItems = show
        Task {
            applyFiltersAndSort()
        }
    }
    
    func sortOrderChanged(_ order: SortOrder) {
        sortOrder = order
        Task {
            applyFiltersAndSort()
        }
    }
    
    @MainActor
    private func performInitialSync() async {
        guard let syncService = syncService else { return }
        
        isSyncing = true
        syncError = nil
        
        do {
            try await syncService.syncItems()
            await loadItems() // reload items after sync
        } catch {
            syncError = error.localizedDescription
            // even if sync fails, still show local data (offline-first)
            print("Sync failed, showing local data: \(error)")
        }
        
        isSyncing = false
    }
    
    @MainActor
    func manualSync() async {
        guard let syncService = syncService else { return }
        
        isSyncing = true
        syncError = nil
        
        do {
            try await syncService.syncItems()
            await loadItems()
        } catch {
            syncError = error.localizedDescription
        }
        
        isSyncing = false
    }
} 
