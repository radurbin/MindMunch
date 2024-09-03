//
//  DeviceActivityReport.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import Foundation

// A struct representing the overall device activity, including total usage duration and a list of app-specific reports.
struct DeviceActivity {
    
    let duration: TimeInterval  // Total duration of device usage in seconds.
    let apps: [AppReport]       // An array of AppReport structs, each representing the usage of a specific app.
    
}
