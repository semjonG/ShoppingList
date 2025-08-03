import Foundation
import Combine

// MARK: - Network Service Protocol

/**
 * Protocol defining the network service for remote data operations.
 * 
 * This protocol abstracts HTTP operations for fetching and uploading shopping list items
 * to/from a remote server, enabling synchronization capabilities.
 */
@MainActor
public protocol NetworkServiceProtocol {
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

@MainActor
public class NetworkService: NetworkServiceProtocol {
    private let baseURL = "https://api.shoppinglist.com" // mock api
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
    }
    
    public func fetchItems(lastSyncTimestamp: Date) async throws -> SyncResponse {
        return try await performWithRetry { [weak self] in
            guard let self = self else {
                throw NetworkError.invalidResponse
            }
            
            let url = URL(string: "\(self.baseURL)/items")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(lastSyncTimestamp.timeIntervalSince1970.description, forHTTPHeaderField: "Last-Sync")
            
            let (data, response) = try await self.session.data(for: request)
            
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
    }
    
    public func uploadItems(_ items: [RemoteItem], lastSyncTimestamp: Date) async throws {
        try await performWithRetry { [weak self] in
            guard let self = self else {
                throw NetworkError.invalidResponse
            }
            
            let url = URL(string: "\(self.baseURL)/items/sync")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let syncRequest = SyncRequest(items: items, lastSyncTimestamp: lastSyncTimestamp)
            request.httpBody = try JSONEncoder().encode(syncRequest)
            
            let (_, response) = try await self.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
        }
    }
    
    // MARK: - Retry Logic with Exponential Back-off
    
    /**
     * Performs an operation with exponential back-off retry logic.
     * 
     * - Parameters:
     *   - operation: The operation to perform
     *   - maxRetries: Maximum number of retry attempts (default: 3)
     *   - baseDelay: Base delay in seconds (default: 1.0)
     * - Returns: The result of the operation
     * - Throws: The last error if all retries fail
     */
    private func performWithRetry<T: Sendable>(
        operation: @escaping @Sendable () async throws -> T,
        maxRetries: Int = 3,
        baseDelay: Double = 1.0
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...maxRetries {
            do {
                return try await operation()
            } catch {
                lastError = error
                
                // Don't retry on the last attempt
                if attempt == maxRetries {
                    break
                }
                
                // Calculate delay with exponential back-off
                let delay = baseDelay * pow(2.0, Double(attempt))
                
                // Add some jitter to prevent thundering herd
                let jitter = Double.random(in: 0...0.1)
                let finalDelay = delay + jitter
                
                print("Network request failed (attempt \(attempt + 1)/\(maxRetries + 1)), retrying in \(finalDelay)s: \(error)")
                
                try await Task.sleep(nanoseconds: UInt64(finalDelay * 1_000_000_000))
            }
        }
        
        throw lastError ?? NetworkError.invalidResponse
    }
}

// MARK: - Mock Network Service for Testing

/**
 * Mock implementation of NetworkServiceProtocol for testing and development.
 * 
 * This class provides a mock implementation that simulates network operations
 * without actually making HTTP requests, useful for testing and development.
 */
@MainActor
public class MockNetworkService: NetworkServiceProtocol {
    private var mockItems: [RemoteItem] = []
    private var lastSyncTimestamp: Date = Date()
    
    public init() {}
    
    public func fetchItems(lastSyncTimestamp: Date) async throws -> SyncResponse {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Return mock data
        return SyncResponse(items: mockItems, lastSyncTimestamp: self.lastSyncTimestamp)
    }
    
    public func uploadItems(_ items: [RemoteItem], lastSyncTimestamp: Date) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Update mock data
        self.mockItems = items
        self.lastSyncTimestamp = lastSyncTimestamp
    }
    
    /**
     * Sets mock data for testing purposes.
     * 
     * - Parameter items: Array of mock items to return in fetch operations
     */
    public func setMockItems(_ items: [RemoteItem]) {
        self.mockItems = items
    }
} 
