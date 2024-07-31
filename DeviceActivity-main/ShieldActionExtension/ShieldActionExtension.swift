//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Riley Durbin on 7/31/24.
//

import ManagedSettings
import UserNotifications

class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            scheduleLocalNotification()
            completionHandler(.close)
        case .secondaryButtonPressed:
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }

    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        scheduleLocalNotification()
        completionHandler(.close)
    }

    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        scheduleLocalNotification()
        completionHandler(.close)
    }

    private func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Open MindMunch"
        content.body = "Tap to open the app."
        content.sound = UNNotificationSound.default
        content.userInfo = ["url": "mindmunchapp://"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
