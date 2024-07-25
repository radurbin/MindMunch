//
//  ShieldConfigurationExtension.swift
//  MyReportExtension
//
//  Created by Riley Durbin on 7/25/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Extension for UIColor to handle hex codes
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    let title = "Hey,\nIt's MunchTime"
    let body = "Go to MindMunch to unlock this app."
    
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.light,
            backgroundColor: UIColor(hex: "#051123"),  // Use the hex color here
            icon: UIImage(named: "munch.png"),
            title: ShieldConfiguration.Label(text: title, color: .white),
            subtitle: ShieldConfiguration.Label(text: body, color: .white),
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: UIColor.black),
            primaryButtonBackgroundColor: .white,
            secondaryButtonLabel: nil)
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
}
