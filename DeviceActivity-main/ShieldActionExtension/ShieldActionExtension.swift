//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Riley Durbin on 7/31/24.
//

import ManagedSettings
import UserNotifications

// A class that handles actions taken on the shield screen, such as pressing buttons.
class ShieldActionExtension: ShieldActionDelegate {
    
    // Handles actions when a user interacts with the shield for a specific application.
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            // Schedule a local notification when the primary button is pressed.
            scheduleLocalNotification()
            completionHandler(.close) // Close the shield.
        case .secondaryButtonPressed:
            completionHandler(.defer) // Defer the action when the secondary button is pressed.
        @unknown default:
            fatalError() // Handle unexpected cases.
        }
    }

    // Handles actions when a user interacts with the shield for a specific web domain.
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Schedule a local notification and close the shield.
        scheduleLocalNotification()
        completionHandler(.close)
    }

    // Handles actions when a user interacts with the shield for a specific activity category.
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Schedule a local notification and close the shield.
        scheduleLocalNotification()
        completionHandler(.close)
    }

    // Schedules a local notification to prompt the user to open the MindMunch app.
    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Open MindMunch" // The title of the notification.
        content.body = "Tap to open the app." // The body text of the notification.
        content.sound = UNNotificationSound.default // The default notification sound.
        content.userInfo = ["url": "mindmunchapp://"] // Custom data to open the app with a specific URL scheme.
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false) // Trigger the notification after 1 second.
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the notification request to the system.
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
