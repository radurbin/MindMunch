//
//  DeviceActivityAppApp.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

@main
struct DeviceActivityApp: App {
    
    @State var showReports = false
    
    let requestAuthorization = RequestAuthorization()
    
    var body: some Scene {
        WindowGroup {
            
            VStack {
                if showReports {
                    MainTabView() // Use the new MainTabView
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
