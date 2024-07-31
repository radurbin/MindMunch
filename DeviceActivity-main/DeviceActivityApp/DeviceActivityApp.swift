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
import DeviceActivity
import FamilyControls

extension DeviceActivityName {
    static let dailyCheck = DeviceActivityName("dailyCheck")
}

@main
struct DeviceActivityApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State var showReports = false
    
    let requestAuthorization = RequestAuthorization()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if showReports {
                    MainTabView()
                } else {
                    Loading(text: "Checking permission...")
                }
            }.onAppear {
                Task {
                    showReports = await requestAuthorization.requestFamilyControls(for: .individual)
                    debugPrint("\(showReports)")
                }
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            ReportsView()
                .tabItem {
                    Label("Screen Time", systemImage: "clock")
                }
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle")
                }
            LimitsView()
                .tabItem {
                    Label("Limits", systemImage: "timer")
                }
            DailyLimitsView()
                .tabItem {
                    Label("Daily Limits", systemImage: "hourglass")
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        BackgroundTaskManager.shared.registerBackgroundTasks()
        
        // Setup the device activity schedule
        setupDeviceActivitySchedule()
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundTaskManager.shared.scheduleAppUsageUpdate()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle notification presentation if needed
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle notification response if needed
        completionHandler()
    }
}

extension AppDelegate {
    func setupDeviceActivitySchedule() {
        let viewModel = DailyLimitsViewModel()
        viewModel.loadDailyLimits()
        
        let center = DeviceActivityCenter()
        
        for limit in viewModel.dailyLimits {
            let activity = DeviceActivityName(limit.id.uuidString)
            let eventName = DeviceActivityEvent.Name("ScreenTimeMonitoring")
            
            let event = DeviceActivityEvent(
                applications: limit.selection.applicationTokens,
                categories: limit.selection.categoryTokens,
                webDomains: limit.selection.webDomainTokens,
                threshold: DateComponents(hour: limit.hours, minute: limit.minutes)
            )
            
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
                intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
                repeats: true
            )
            
            do {
                try center.startMonitoring(
                    activity,
                    during: schedule,
                    events: [eventName: event]
                )
                print("Started monitoring for \(activity.rawValue) with event \(eventName.rawValue)")
            } catch {
                print("Failed to start monitoring for \(activity.rawValue): \(error.localizedDescription)")
            }
        }
    }
}
