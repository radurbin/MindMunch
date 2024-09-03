//
//  TotalActivityReport.swift
//  MonitorReport
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import DeviceActivity
import SwiftUI

// Extension to define a custom context for the DeviceActivityReport.
extension DeviceActivityReport.Context {
    static let totalActivity = Self("Atividades") // A custom context named "Atividades" for tracking total device activity.
}

// A struct representing the total activity report, implementing the DeviceActivityReportScene protocol.
struct TotalActivityReport: DeviceActivityReportScene {
    
    // The context in which this report operates, using the custom context defined above.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // A closure that takes a DeviceActivity object and returns a TotalActivityView.
    let content: (DeviceActivity) -> TotalActivityView
    
    // Asynchronously configures the report by processing the DeviceActivityResults data.
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> DeviceActivity {
        
        var list: [AppReport] = [] // An array to store app usage reports.
        
        // Calculate the total duration of device activity by summing the duration of all activity segments.
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
        
        // Process each activity segment and its categories to extract app usage data.
        for await _data in data {
            for await activity in _data.activitySegments {
                for await category in activity.categories {
                    for await app in category.applications {
                        let appName = (app.application.localizedDisplayName ?? "nil") // Get the app's display name or "nil" if unavailable.
                        let bundle = (app.application.bundleIdentifier ?? "nil")      // Get the app's bundle identifier or "nil" if unavailable.
                        let duration = app.totalActivityDuration                     // Get the total activity duration for the app.
                        let app = AppReport(id: bundle, name: appName, duration: duration) // Create an AppReport instance.
                        list.append(app) // Add the AppReport to the list.
                    }
                }
            }
        }
        
        // Return a DeviceActivity instance with the total duration and the list of app reports.
        return DeviceActivity(duration: totalActivityDuration, apps: list)
    }
}
