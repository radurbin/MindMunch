//
//  ActivitiesView.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

// ActivitiesView.swift
import SwiftUI

struct ActivitiesView: View {
    var activities: DeviceActivity
    
    var body: some View {
        VStack {
                    // Header with logo
                    GeometryReader { geometry in
                        VStack {
                            Image("logo-with-sub")
                                .resizable()
//                                .scaledToFit()
                                .frame(width: 350, height: 350)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
                        .background(Color(hex: "#0B132B"))
                    }
                    .frame(height: 35)
                    .padding(.top, 10)
                    .padding(.bottom, 10)// Adjust the height as needed

                    Text("Usage time: \(formatUsageTime(activities.duration))")
                        .bold()
                        .font(.title)
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .padding(.bottom, 10)

            List(filteredAndSortedApps(activities.apps)) { app in
                ListItem(app: app)
                    .listRowBackground(Color.clear)
            }
            .background(Color.clear)
            .listStyle(PlainListStyle())
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .environment(\.colorScheme, .dark)
    }
    
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
    
    private func filteredAndSortedApps(_ apps: [AppReport]) -> [AppReport] {
        return apps
            .filter { $0.duration > 0 }
            .sorted { $0.duration > $1.duration }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitiesView(activities: DeviceActivity(duration: 3422, apps: [
            AppReport(id: "1", name: "Twitter", duration: 600),
            AppReport(id: "2", name: "Facebook", duration: 1200),
            AppReport(id: "3", name: "Instagram", duration: 300),
            AppReport(id: "4", name: "EmptyApp", duration: 0)
        ]))
    }
}
