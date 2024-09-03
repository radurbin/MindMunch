//
//  ActivitiesView.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// A view that displays the device activity, including total usage time and a list of app-specific reports.
struct ActivitiesView: View {
    var activities: DeviceActivity // The device activity data to be displayed.
    
    // The body of the view, defining the user interface.
    var body: some View {
        VStack {
            // Header section with a logo.
            GeometryReader { geometry in
                VStack {
                    Image("logo-with-sub")
                        .resizable()
                        .frame(width: 350, height: 350) // Set the size of the logo.
                }
                .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                .background(Color(hex: "#0B132B")) // Background color for the header.
            }
            .frame(height: 35)
            .padding(.top, 10)
            .padding(.bottom, 10)

            // Display the total usage time.
            Text("Usage time: \(formatUsageTime(activities.duration))")
                .bold()
                .font(.title)
                .foregroundColor(Color(hex: "#FFFFFF"))
                .padding(.bottom, 10)

            // List of app reports, filtered and sorted by duration.
            List(filteredAndSortedApps(activities.apps)) { app in
                ListItem(app: app)
                    .listRowBackground(Color.clear) // Ensure transparent background for rows.
            }
            .background(Color.clear)
            .listStyle(PlainListStyle()) // Use a plain list style.
        }
        // Background gradient for the entire view.
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .environment(\.colorScheme, .dark) // Force the color scheme to dark mode.
    }
    
    // Formats the usage time (in seconds) into a string in the format "HHh MMm SSs".
    private func formatUsageTime(_ duration: TimeInterval) -> String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %02dm %02ds", hours, minutes, seconds)
        } else {
            return String(format: "%02dm %02ds", minutes, seconds)
        }
    }
    
    // Filters out apps with zero duration and sorts the remaining apps by duration in descending order.
    private func filteredAndSortedApps(_ apps: [AppReport]) -> [AppReport] {
        return apps
            .filter { $0.duration > 0 } // Filter out apps with no usage time.
            .sorted { $0.duration > $1.duration } // Sort apps by duration (longest first).
    }
}

// A preview provider for the ActivitiesView, useful for visualizing the view in Xcode's canvas.
struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(activities: DeviceActivity(duration: 3422, apps: [
            AppReport(id: "1", name: "Twitter", duration: 600),
            AppReport(id: "2", name: "Facebook", duration: 1200),
            AppReport(id: "3", name: "Instagram", duration: 300),
            AppReport(id: "4", name: "EmptyApp", duration: 0) // An app with zero usage time.
        ]))
    }
}
