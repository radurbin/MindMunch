//
//  MonitorReport.swift
//  MonitorReport
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import DeviceActivity
import SwiftUI

// The main entry point for the DeviceActivityReport extension in the app.
@main
struct MonitorReport: DeviceActivityReportExtension {
    
    // The body of the report extension, defining the scenes that provide device activity reports.
    var body: some DeviceActivityReportScene {
        // Creates a report for the total activity, using the TotalActivityReport context.
        TotalActivityReport { activity in
            TotalActivityView(deviceActivity: activity) // Pass the activity data to the TotalActivityView.
        }
        // Additional reports can be added here by defining more DeviceActivityReportScene instances.
    }
}
