//
//  NotificationManager.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/25/24.
//

import Foundation
import UserNotifications

// A singleton class that manages notification-related functionality for the app.
class NotificationManager {
    // Shared instance of the NotificationManager to ensure a single instance is used throughout the app.
    static let shared = NotificationManager()
    
    // Private initializer to prevent the creation of additional instances of NotificationManager.
    private init() {}
    
    // Requests authorization from the user to display notifications.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                // Print an error message if the authorization request fails.
                print("Error requesting notification authorization: \(error.localizedDescription)")
            } else {
                // Print whether the authorization was granted or denied.
                print("Notification authorization granted: \(granted)")
            }
        }
    }
}
