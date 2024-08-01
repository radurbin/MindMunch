//
//  NotificationManager.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/25/24.
//

//import Foundation
//import UserNotifications

//class NotificationManager {
//    static let shared = NotificationManager()
//    
//    private init() {}
//    
//    // Remove scheduling and cancelling notification methods
//}

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            } else {
                print("Notification authorization granted: \(granted)")
            }
        }
    }
    
    // Optionally, you can add methods to schedule and cancel notifications
}


//class NotificationManager {
//    static let shared = NotificationManager()
//    
//    func requestAuthorization() {
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
//            if let error = error {
//                print("Error requesting notification authorization: \(error.localizedDescription)")
//            } else {
//                print("Notification authorization granted: \(granted)")
//            }
//        }
//    }
//    
////    func scheduleNotification(for limit: AppLimit) {
////        let content = UNMutableNotificationContent()
////        content.title = "Screen Time Limit Reached"
////        content.body = "Your limit for selected apps has been reached."
////        content.sound = .default
////        
////        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: limit.remainingTime, repeats: false)
////        
////        let request = UNNotificationRequest(identifier: limit.id.uuidString, content: content, trigger: trigger)
////        
////        UNUserNotificationCenter.current().add(request) { error in
////            if let error = error {
////                print("Error scheduling notification: \(error.localizedDescription)")
////            } else {
////                print("Notification scheduled for \(limit.remainingTime) seconds.")
////            }
////        }
////    }
////    
////    func cancelNotification(for limit: AppLimit) {
////        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [limit.id.uuidString])
////        print("Notification cancelled for limit \(limit.id.uuidString).")
////    }
//}
