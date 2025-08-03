//
//  MockSyncService.swift
//  ShoppingListFeatureTests
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
@testable import ShoppingListFeature

@MainActor
class MockSyncService: SyncServiceProtocol {
    var shouldThrowError = false
    var lastError: Error = NSError(domain: "Test", code: 0)
    var isSyncing = false
    var syncError: String?
    
    func syncItems() async throws {
        if shouldThrowError {
            throw lastError
        }
        
        isSyncing = true
        // Simulate sync delay
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        isSyncing = false
    }
    
    func registerBackgroundTasks() {
        // Mock implementation - no actual background task registration
    }
} 