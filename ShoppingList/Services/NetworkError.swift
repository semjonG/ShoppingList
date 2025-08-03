//
//  NetworkError.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation

// MARK: - Network Errors

/**
 * Defines network-related errors that can occur during API operations.
 * 
 * This enum provides structured error handling for network operations,
 * including server errors, connectivity issues, and data parsing problems.
 */
enum NetworkError: Error, LocalizedError {
    /// The server response was invalid or malformed
    case invalidResponse
    
    /// The server returned an error with the specified HTTP status code
    case serverError(Int)
    
    /// Failed to decode the server response into the expected data structure
    case decodingError
    
    /// No internet connection is available
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode server response"
        case .noInternetConnection:
            return "No internet connection"
        }
    }
} 