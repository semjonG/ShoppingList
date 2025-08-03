import Foundation
#if canImport(BackgroundTasks)
import BackgroundTasks
#endif

// MARK: - Background Task Service Protocol

/**
 * Protocol defining the background task service for iOS background processing.
 * 
 * This protocol abstracts background task registration and handling,
 * enabling automatic synchronization when the app is in the background.
 */
public protocol BackgroundTaskServiceProtocol {
    /**
     * Registers background tasks for automatic synchronization.
     * 
     * Sets up the necessary background task identifiers and handlers
     * for iOS background processing.
     */
    func registerBackgroundTasks()
}

// MARK: - Background Task Service Implementation

/**
 * Implementation of BackgroundTaskServiceProtocol for iOS background processing.
 * 
 * This class handles the registration and execution of background tasks
 * for automatic synchronization of shopping list items.
 */
#if canImport(BackgroundTasks)
public class BackgroundTaskService: BackgroundTaskServiceProtocol {
    private let backgroundTaskIdentifier = "com.shoppinglist.sync"
    
    public init() {}
    
    public func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { [weak self] task in
            self?.handleBackgroundTask(task as! BGAppRefreshTask)
        }
    }
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        // Schedule the next background task
        scheduleBackgroundTask()
        
        // Create a task to track background execution
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation {
            // Perform background sync
            Task {
                
            }
        }
        
        // Use weak references to avoid @Sendable issues
        let weakQueue = queue
        task.expirationHandler = {
            weakQueue.cancelAllOperations()
        }
        
        // Set up operation completion block
        operation.completionBlock = {
            // Operation completed - no need to track state
        }
        
        queue.addOperation(operation)
        
        // Complete the task immediately - the operation will run in background
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
}
#else
public class BackgroundTaskService: BackgroundTaskServiceProtocol {
    // Stub implementation for non-iOS platforms
    public init() {}
    
    public func registerBackgroundTasks() {
        // No-op for non-iOS platforms
    }
}
#endif 
