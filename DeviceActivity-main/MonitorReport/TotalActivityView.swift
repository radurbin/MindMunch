//
//  TotalActivityView.swift
//  MonitorReport
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// A view that displays the total device activity by using the ActivitiesView.
struct TotalActivityView: View {
    
    var deviceActivity: DeviceActivity // The device activity data to be displayed.
    
    // The body of the view, which renders the ActivitiesView with the provided device activity data.
    var body: some View {
        ActivitiesView(activities: deviceActivity)
    }
}
