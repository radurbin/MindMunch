//
//  ActivitiesView.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

struct ActivitiesView: View {
    var activities: DeviceActivity
    
    var body: some View {
        VStack {
            Spacer(minLength: 50)
            
            // Display total usage time
            Text("Usage time: \(formatTotalUsageTime(activities.apps))")
                .bold()
                .font(.title3)
            
            List(activities.apps) { app in
                ListItem(app: app)
            }
        }
    }
    
    // Function to calculate and format total usage time
    private func formatTotalUsageTime(_ apps: [AppReport]) -> String {
        let totalSeconds = apps.reduce(0) { $0 + $1.duration }
        let hours = Int(totalSeconds) / 3600
        let minutes = (Int(totalSeconds) % 3600) / 60
        let seconds = Int(totalSeconds) % 60
        
        return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(activities: DeviceActivity(duration: .zero, apps: [AppReport(id: "1", name: "Twitter", duration: .zero)]))
    }
}
