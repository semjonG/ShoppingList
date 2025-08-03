//
//  SyncService.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import Combine
import BackgroundTasks

// MARK: - Sync Service Protocol

/**
 * Protocol defining the synchronization service for shopping list items.
 * 
 * This protocol abstracts the synchronization operations between local and remote data,
 * enabling offline-first functionality with background sync capabilities.
 */
protocol SyncServiceProtocol {
    /**
     * Performs a manual synchronization of shopping list items.
     * 
     * Fetches remote changes and uploads local changes to maintain data consistency.
     * - Throws: An error if the sync operation fails
     */
    func syncItems() async throws
    
    /**
     * Performs background synchronization of shopping list items.
     * 
     * Similar to syncItems() but designed for background execution.
     * - Throws: An error if the background sync operation fails
     */
    func performBackgroundSync() async throws
    
    /**
     * Registers background tasks for automatic synchronization.
     * 
     * Sets up the necessary background task identifiers and handlers
     * for iOS background processing.
     */
    func registerBackgroundTasks()
}

// MARK: - Sync Service Implementation

class SyncService: SyncServiceProtocol {
    private let networkService: NetworkServiceProtocol
    private let repository: ShoppingListRepositoryProtocol
    private let backgroundTaskService: BackgroundTaskServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isSyncing = false
    @Published var lastSyncTimestamp: Date = Date.distantPast
    @Published var syncError: String?
    
    init(
        networkService: NetworkServiceProtocol,
        repository: ShoppingListRepositoryProtocol,
        backgroundTaskService: BackgroundTaskServiceProtocol
    ) {
        self.networkService = networkService
        self.repository = repository
        self.backgroundTaskService = backgroundTaskService
    }
    
    func syncItems() async throws {
        try await performSync()
    }
    
    func performBackgroundSync() async throws {
        try await performSync()
    }
    
    func registerBackgroundTasks() {
        backgroundTaskService.registerBackgroundTasks()
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
        } catch {
            syncError = error.localizedDescription
            throw error
        }
        
        isSyncing = false
    }
    
    private func mergeRemoteItems(_ remoteItems: [RemoteItem]) async throws {
        // simple last-write-wins conflict resolution
        // in a real project implement proper conflict resolution
        print("Merging \(remoteItems.count) remote items")
        
        // just log the remote items
        for remoteItem in remoteItems {
            print("Remote item: \(remoteItem.name) (updated: \(remoteItem.updatedAt))")
        }
    }
    
    private func uploadLocalChanges() async throws {
        // get local items and upload them
        let items = try await repository.fetchItems()
        let remoteItems = items.map { RemoteItem(from: $0) }
        try await networkService.uploadItems(remoteItems, lastSyncTimestamp: lastSyncTimestamp)
    }
} 
