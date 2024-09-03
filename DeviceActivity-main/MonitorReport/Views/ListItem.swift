//
//  List.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// A view that represents a single item in a list, displaying information about a specific app's usage.
struct ListItem: View {
    private let app: AppReport // The app report data to be displayed in the list item.
    
    // Initializer to set the app data for the list item.
    init(app: AppReport) {
        self.app = app
    }
    
    // The body of the view, defining the user interface for the list item.
    var body: some View {
        HStack {
            // Display the name of the app.
            Text(app.name)
                .font(.headline)
                .foregroundColor(Color(hex: "#FFFFFF")) // Set the text color to white.
            
            Spacer() // Spacer to push the following text to the right.
            
            // Display the formatted usage time of the app.
            Text(formatUsageTime(app.duration))
                .font(.subheadline)
                .foregroundColor(Color(hex: "#FFFFFF")) // Set the text color to white.
        }
        .padding() // Add padding around the entire HStack.
        .background(Color(hex: "#1C2541")) // Set the background color of the list item.
        .cornerRadius(10) // Round the corners of the background.
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
}

// A preview provider for the ListItem view, useful for visualizing the view in Xcode's canvas.
struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(app: AppReport(id: "1", name: "Twitter", duration: 600)) // Example app report data for preview.
    }
}
