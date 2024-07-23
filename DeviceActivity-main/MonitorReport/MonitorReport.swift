//
//  MonitorReport.swift
//  MonitorReport
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import DeviceActivity
import SwiftUI

@main
struct MonitorReport: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { activity in
            TotalActivityView(deviceActivity: activity)
        }
        // Add more reports here...
    }
}
