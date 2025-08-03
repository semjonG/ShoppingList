import Foundation
import Combine

// MARK: - Sync Service Protocol

/**
 * Protocol defining the synchronization service for shopping list items.
 * 
 * This protocol abstracts the synchronization operations between local and remote data,
 * enabling offline-first functionality with background sync capabilities.
 */
@MainActor
public protocol SyncServiceProtocol {
    /**
     * Performs synchronization of shopping list items.
     * 
     * Fetches remote changes and uploads local changes to maintain data consistency.
     * - Throws: An error if the sync operation fails
     */
    func syncItems() async throws
    
    /**
     * Registers background tasks for automatic synchronization.
     * 
     * Sets up the necessary background task identifiers and handlers
     * for iOS background processing.
     */
    func registerBackgroundTasks()
}

// MARK: - Sync Service Implementation

@MainActor
public class SyncService: SyncServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let repository: ShoppingListRepositoryProtocol
    private let backgroundTaskService: BackgroundTaskServiceProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var isSyncing = false
    @Published public var lastSyncTimestamp: Date = Date.distantPast
    @Published public var syncError: String?
    
    public init(
        networkService: NetworkServiceProtocol,
        repository: ShoppingListRepositoryProtocol,
        backgroundTaskService: BackgroundTaskServiceProtocol? = nil
    ) {
        self.networkService = networkService
        self.repository = repository
        self.backgroundTaskService = backgroundTaskService
    }
    
    public func syncItems() async throws {
        try await performSync()
    }
    
    public func registerBackgroundTasks() {
        backgroundTaskService?.registerBackgroundTasks()
    }
    
    private func performSync() async throws {
        guard !isSyncing else {
            return
        }
        
        isSyncing = true
        syncError = nil
        
        do {
            let response = try await networkService.fetchItems(lastSyncTimestamp: lastSyncTimestamp)
            try await mergeRemoteItems(response.items)
            try await uploadLocalChanges()
            lastSyncTimestamp = response.lastSyncTimestamp
        } catch {
            syncError = error.localizedDescription
            throw error
        }
        
        isSyncing = false
    }
    
    private func mergeRemoteItems(_ remoteItems: [RemoteItem]) async throws {
        let localItems = try await repository.fetchItems()
        
        for remoteItem in remoteItems {
            if let localItem = localItems.first(where: { $0.syncId == remoteItem.id }) {
                // Last-write-wins strategy: use the most recently updated item
                if remoteItem.updatedAt > localItem.updatedAt {
                    print("Remote item is newer, updating local item: \(remoteItem.name)")
                    localItem.update(
                        name: remoteItem.name,
                        quantity: remoteItem.quantity,
                        note: remoteItem.note
                    )
                    if remoteItem.isBought != localItem.isBought {
                        if remoteItem.isBought {
                            localItem.markAsBought()
                        } else {
                            localItem.markAsNotBought()
                        }
                    }
                } else {
                    print("Local item is newer, keeping local version: \(localItem.name)")
                }
            } else {
                // Create new item from remote
                print("Creating new item from remote: \(remoteItem.name)")
                try await repository.addItem(
                    name: remoteItem.name,
                    quantity: remoteItem.quantity,
                    note: remoteItem.note
                )
            }
        }
    }
    
    private func uploadLocalChanges() async throws {
        let localItems = try await repository.fetchItems()
        let remoteItems = localItems.map { RemoteItem(from: $0) }
        
        try await networkService.uploadItems(remoteItems, lastSyncTimestamp: lastSyncTimestamp)
    }
} 
