//
//  ColorExtensions.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/30/24.
//

import SwiftUI

// Extension to the Color struct that adds the ability to create a Color from a hexadecimal string.
extension Color {
    // Initializes a Color instance from a hexadecimal string.
    init(hex: String) {
        // Trims non-alphanumeric characters from the string (e.g., "#").
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        // Scans the hex string and converts it into an integer.
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit): e.g., "F00" -> "FF0000"
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit): e.g., "FF0000" (Red)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit): e.g., "FFFF0000" (Red with full opacity)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: // Default to black if the hex string is invalid.
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        // Initializes the Color with the calculated red, green, blue, and opacity values.
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
