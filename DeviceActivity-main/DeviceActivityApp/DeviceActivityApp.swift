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
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Remove notification presentation handler
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Remove notification response handler
    }
}
