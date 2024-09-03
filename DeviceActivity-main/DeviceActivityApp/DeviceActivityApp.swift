//
//  DeviceActivityAppApp.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI
import UIKit
import UserNotifications
import BackgroundTasks

// The main entry point of the app, where the app's structure and behavior are defined.
@main
struct DeviceActivityApp: App {
    // AppDelegate integration for handling background tasks, notifications, and app lifecycle events.
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // State variable to control whether the reports screen should be shown.
    @State var showReports = false
    
    // Instance of RequestAuthorization for managing permissions.
    let requestAuthorization = RequestAuthorization()
    
    // The main scene of the app, defining the initial UI structure.
    var body: some Scene {
        WindowGroup {
            VStack {
                // Conditionally show either the main tab view or a loading screen based on permissions.
                if showReports {
                    MainTabView()
                } else {
                    Loading(text: "Checking permission...")
                }
            }
            // Asynchronously request FamilyControls permissions on view appearance.
            .onAppear {
                Task {
                    showReports = await requestAuthorization.requestFamilyControls(for: .individual)
                    debugPrint("\(showReports)")
                }
            }
        }
    }
}

// A view that represents the main tab-based navigation of the app.
struct MainTabView: View {
    var body: some View {
        TabView {
            ReportsView()
                .tabItem {
                    Label("Screen Time", systemImage: "clock")
                }
            QuizView()
                .tabItem {
                    Label("Munches", systemImage: "questionmark.circle")
                }
            LimitsView()
                .tabItem {
                    Label("Limits", systemImage: "timer")
                }
        }
        // Force the color scheme to dark mode for the entire tab view.
        .environment(\.colorScheme, .dark)
    }
}

// AppDelegate class to manage background tasks, notifications, and app lifecycle events.
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Called when the app has finished launching. Configures notifications and background tasks.
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions.
        NotificationManager.shared.requestAuthorization()
        
        // Register background tasks.
        BackgroundTaskManager.shared.registerBackgroundTasks()
        return true
    }
    
    // Called when the app enters the background. Schedules the app usage update task.
    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundTaskManager.shared.scheduleAppUsageUpdate()
    }
    
    // Handles the presentation of notifications while the app is in the foreground.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    // Handles the user's interaction with a notification.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // If the notification contains a URL, attempt to open it.
        if let url = response.notification.request.content.userInfo["url"] as? String, let appURL = URL(string: url) {
            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
        }
        completionHandler()
    }
}
