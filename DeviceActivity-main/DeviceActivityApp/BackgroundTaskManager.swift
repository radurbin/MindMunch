//
//  BackgroundTaskManager.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/25/24.
//

import BackgroundTasks
import Foundation
import UIKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    private init() {}
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.example.MindMunch.updateUsage", using: nil) { task in
            self.handleAppUsageUpdate(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleAppUsageUpdate() {
        let request = BGProcessingTaskRequest(identifier: "com.example.MindMunch.updateUsage")
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to submit BGProcessingTaskRequest: \(error)")
        }
    }
    
    private func handleAppUsageUpdate(task: BGProcessingTask) {
        scheduleAppUsageUpdate()
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        let operation = UpdateAppUsageOperation { success in
            task.setTaskCompleted(success: success)
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        queue.addOperation(operation)
    }
}

class UpdateAppUsageOperation: Operation {
    private let completion: (Bool) -> Void
    
    init(completion: @escaping (Bool) -> Void) {
        self.completion = completion
    }
    
    override func main() {
        guard !isCancelled else {
            completion(false)
            return
        }
        
        // Update app usage logic here
        LimitsViewModel().updateAppUsage()
        
        completion(true)
    }
}
