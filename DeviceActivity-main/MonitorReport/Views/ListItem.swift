//
//  List.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

// ListItem.swift
import SwiftUI

struct ListItem: View {
    private let app: AppReport
    
    init(app: AppReport) {
        self.app = app
    }
    
    var body: some View {
        HStack {
            Text(app.name)
                .font(.headline)
                .foregroundColor(Color(hex: "#FFFFFF"))
            
            Spacer()
            
            Text(formatUsageTime(app.duration))
                .font(.subheadline)
                .foregroundColor(Color(hex: "#FFFFFF"))
        }
        .padding()
        .background(Color(hex: "#1C2541"))
        .cornerRadius(10)
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
}

struct ListItem_Previews: PreviewProvider {
    static var previews: some View {
        ListItem(app: AppReport(id: "1", name: "Twitter", duration: 600))
    }
}
