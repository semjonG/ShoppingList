import Foundation
import SwiftUI

@MainActor
public class ShoppingListViewModel: ObservableObject {
    @Published public var items: [Item] = []
    @Published public var filteredItems: [Item] = []
    @Published public var searchText = ""
    @Published public var showBoughtItems = false
    @Published public var sortOrder: SortOrder = .createdAtDescending
    @Published public var isLoading = false
    @Published public var errorMessage: String?
    @Published public var showingAddItem = false
    @Published public var editingItem: Item?
    @Published public var syncError: String?
    
    private var repository: ShoppingListRepositoryProtocol
    private let syncService: SyncServiceProtocol?
    
    public init(repository: ShoppingListRepositoryProtocol, syncService: SyncServiceProtocol? = nil) {
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
    public func loadItems() async {
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
    public func addItem(name: String, quantity: Int, note: String?) async {
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
            
            // Note: Sync is handled automatically by the sync service
            // No manual trigger needed to avoid data races
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func updateItem(_ item: Item, name: String, quantity: Int, note: String?) async {
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
    public func deleteItem(_ item: Item) async {
        do {
            try await repository.deleteItem(item)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    public func toggleBoughtStatus(for item: Item) async {
        do {
            try await repository.toggleBoughtStatus(for: item)
            await loadItems()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    public func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Debounced Input Handlers
    
    public func searchTextChanged(_ text: String) {
        searchText = text
        Task {
            try? await Task.sleep(for: .milliseconds(300))
            applyFiltersAndSort()
        }
    }
    
    public func showBoughtItemsChanged(_ show: Bool) {
        showBoughtItems = show
        Task {
            applyFiltersAndSort()
        }
    }
    
    public func sortOrderChanged(_ order: SortOrder) {
        sortOrder = order
        Task {
            applyFiltersAndSort()
        }
    }
    
    @MainActor
    private func performInitialSync() async {
        // Skip sync if no sync service available
        guard let syncService = syncService else { return }
        
        syncError = nil
        
        do {
            // Perform sync directly since we're already on main actor
            try await syncService.syncItems()
            await loadItems() // reload items after sync
        } catch {
            syncError = error.localizedDescription
            // even if sync fails, still show local data (offline-first)
            print("Sync failed, showing local data: \(error)")
        }
    }
} 
