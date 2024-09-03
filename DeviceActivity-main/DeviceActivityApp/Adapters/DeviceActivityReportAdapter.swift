//
//  DeviceActivityReportAdapter.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI
import DeviceActivity

// A SwiftUI View that adapts and displays a DeviceActivityReport within the app's UI.
struct DeviceActivityReporterAdapter: View {
    
    // State property to hold the context for the DeviceActivityReport.
    @State private var context: DeviceActivityReport.Context = .init(rawValue: "Atividades")
    
    // State property to configure the filter for the DeviceActivityReport.
    // The filter is set to show daily activity for all users and devices, specifically targeting iPhone.
    @State private var filter = DeviceActivityFilter(
        segment: .daily(
            during: Calendar.current.dateInterval(
                of: .day, for: .now
            )!
        ),
        users: .all,
        devices: .init([.iPhone])
    )
    
    // The body of the view, which contains a ZStack that displays the DeviceActivityReport
    // using the specified context and filter.
    var body: some View {
        ZStack {
            DeviceActivityReport(context, filter: filter)
        }
    }
    
}
