//
//  NetworkService.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import Combine

// MARK: - Network Service Protocol

/**
 * Protocol defining the network service for remote data operations.
 * 
 * This protocol abstracts HTTP operations for fetching and uploading shopping list items
 * to/from a remote server, enabling synchronization capabilities.
 */
protocol NetworkServiceProtocol {
    /**
     * Fetches shopping list items from the remote server.
     * 
     * - Parameters:
     *   - lastSyncTimestamp: The timestamp of the last successful sync to fetch only new changes
     * - Returns: A SyncResponse containing the remote items and sync metadata
     * - Throws: A NetworkError if the fetch operation fails
     */
    func fetchItems(lastSyncTimestamp: Date) async throws -> SyncResponse
    
    /**
     * Uploads local shopping list items to the remote server.
     * 
     * - Parameters:
     *   - items: Array of local items to upload to the server
     *   - lastSyncTimestamp: The timestamp of the last successful sync for conflict resolution
     * - Throws: A NetworkError if the upload operation fails
     */
    func uploadItems(_ items: [RemoteItem], lastSyncTimestamp: Date) async throws
}

// MARK: - Network Service Implementation

class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.shoppinglist.com" // mock api
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    func fetchItems(lastSyncTimestamp: Date) async throws -> SyncResponse {
        let url = URL(string: "\(baseURL)/items")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(lastSyncTimestamp.timeIntervalSince1970.description, forHTTPHeaderField: "Last-Sync")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(SyncResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func uploadItems(_ items: [RemoteItem], lastSyncTimestamp: Date) async throws {
        let url = URL(string: "\(baseURL)/items/sync")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let syncRequest = SyncRequest(items: items, lastSyncTimestamp: lastSyncTimestamp)
        request.httpBody = try JSONEncoder().encode(syncRequest)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}

// MARK: - Mock Network Service for Testing

class MockNetworkService: NetworkService {
    override func fetchItems(lastSyncTimestamp: Date) async throws -> SyncResponse {
        // simulate network delay
        try await Task.sleep(for: .seconds(1))
        
        // simulate successful response with mock data
        let mockItems = [
            RemoteItem(
                id: "remote-1",
                name: "Remote Milk",
                quantity: 2,
                note: "From server",
                isBought: false,
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
        
        let response = SyncResponse(
            items: mockItems,
            lastSyncTimestamp: Date()
        )
        
        return response
    }
    
    override func uploadItems(_ items: [RemoteItem], lastSyncTimestamp: Date) async throws {
        // simulate network delay
        try await Task.sleep(for: .milliseconds(500))
        
        // simulate successful upload
    }
} 
