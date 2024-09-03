//
//  AppReport.swift
//  Monitor
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import Foundation

// A struct representing a report for a specific app, including its name, duration of usage, and a unique identifier.
struct AppReport: Identifiable {
    var id: String            // Unique identifier for the app report.
    var name: String          // Name of the app.
    var duration: TimeInterval // Duration of app usage in seconds.
}

// Extension to the TimeInterval type to add functionality for converting time intervals into a formatted string.
extension TimeInterval {
    
    // Converts the TimeInterval into a string formatted as "HH:mm".
    func toString() -> String {
        let time = NSInteger(self) // Convert the TimeInterval to an integer.
        
        // Extract milliseconds, seconds, minutes, and hours from the time interval.
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000) // Milliseconds
        let seconds = time % 60                                        // Seconds
        let minutes = (time / 60) % 60                                 // Minutes
        let hours = (time / 3600)                                      // Hours
        
        // Format the time into a string "HH:mm".
        return String(format: "%0.2d:%0.2d", hours, minutes)
    }
}
