//
//  BackgroundTaskService.swift
//  ShoppingList
//
//  Created by Sam Gerasimov on 02.08.2025.
//

import Foundation
import BackgroundTasks
import Combine

// MARK: - Background Task Service Protocol

/**
 * Protocol defining the background task service for iOS background processing.
 * 
 * This protocol abstracts the iOS BackgroundTasks framework operations,
 * enabling automatic synchronization of shopping list items in the background.
 */
protocol BackgroundTaskServiceProtocol {
    /**
     * Registers background tasks with the iOS system.
     * 
     * Sets up the necessary background task identifiers and handlers
     * for automatic background processing.
     */
    func registerBackgroundTasks()
    
    /**
     * Schedules a background sync task for future execution.
     * 
     * Requests the iOS system to run a background sync task
     * at an appropriate time (typically when the app is not active).
     */
    func scheduleBackgroundSync()
    
    /**
     * Handles the execution of a background sync task.
     * 
     * - Parameters:
     *   - completion: Closure to call when the background task completes
     *     - success: Boolean indicating whether the task completed successfully
     */
    func handleBackgroundSync(completion: @escaping (Bool) -> Void)
}

// MARK: - Background Task Service Implementation

class BackgroundTaskService: BackgroundTaskServiceProtocol {
    private let backgroundTaskIdentifier = "com.shoppinglist.sync"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        registerBackgroundTasks()
    }
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleBackgroundSync { success in
                task.setTaskCompleted(success: success)
            }
        }
    }
    
    func scheduleBackgroundSync() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background sync: \(error)")
        }
    }
    
    func handleBackgroundSync(completion: @escaping (Bool) -> Void) {
        // schedule the next background sync
        scheduleBackgroundSync()
        
        // for now, just complete successfully, its a stub
        // in a real implementation inject the sync service (real one)
        completion(true)
    }
} 
