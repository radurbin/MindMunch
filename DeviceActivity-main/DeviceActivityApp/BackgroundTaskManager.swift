//
//  BackgroundTaskManager.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/25/24.
//

import BackgroundTasks
import Foundation
import UIKit

// A singleton class that manages background tasks for the app.
class BackgroundTaskManager {
    // Shared instance of the BackgroundTaskManager to ensure a single instance is used throughout the app.
    static let shared = BackgroundTaskManager()
    
    // Private initializer to prevent the creation of additional instances of BackgroundTaskManager.
    private init() {}
    
    // Registers background tasks with the system.
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.MindMunch.updateUsage", using: nil) { task in
            self.handleAppUsageUpdate(task: task as! BGProcessingTask)
        }
    }
    
    // Schedules the app usage update background task.
    func scheduleAppUsageUpdate() {
        let request = BGProcessingTaskRequest(identifier: "com.example.MindMunch.updateUsage")
        request.requiresNetworkConnectivity = false // Task does not require network connectivity.
        request.requiresExternalPower = false // Task does not require external power.
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // Start the task at least 15 minutes from now.
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            // Handle the error if the task submission fails.
            print("Failed to submit BGProcessingTaskRequest: \(error)")
        }
    }
    
    // Handles the execution of the app usage update task.
    private func handleAppUsageUpdate(task: BGProcessingTask) {
        // Reschedule the task to ensure continuous updates.
        scheduleAppUsageUpdate()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1 // Limit the operation queue to one operation at a time.
        
        // Create an operation to update app usage.
        let operation = UpdateAppUsageOperation { success in
            task.setTaskCompleted(success: success) // Mark the task as completed.
        }
        
        // Handle task expiration by canceling all operations.
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        // Add the operation to the queue for execution.
        queue.addOperation(operation)
    }
}

// A custom operation that handles the app usage update process.
class UpdateAppUsageOperation: Operation {
    private let completion: (Bool) -> Void
    
    // Initializer for the operation, accepting a completion handler to signal the success or failure of the task.
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    // The main method where the operation's work is performed.
    override func main() {
        // If the operation is canceled before it begins, mark it as failed.
        guard !isCancelled else {
            completion(false)
            return
        }
        
        // Perform the app usage update logic here.
        LimitsViewModel().updateAppUsage()
        
        // Mark the operation as successful.
        completion(true)
    }
}
