//
//  ShieldConfigurationExtension.swift
//  MyReportExtension
//
//  Created by Riley Durbin on 7/25/24.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Extension for UIColor to initialize colors from hex strings.
extension UIColor {
    convenience init(hex: String) {
        // Sanitize the hex string by trimming whitespace and removing the "#" symbol.
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        // Convert the hex string to a UInt64 value representing the RGB components.
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        // Extract the red, green, and blue components from the RGB value.
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        // Initialize the UIColor with the extracted RGB values.
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

// A class that customizes the shield configuration used in the ManagedSettings framework.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    // Properties for customizing the shield's title and body text.
    let title = "Hey,\nIt's MunchTime"
    let body = "Go to MindMunch to unlock this app."
    
    // Customizes the shield configuration for a specific application.
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        return ShieldConfiguration(
            backgroundBlurStyle: UIBlurEffect.Style.light, // Light blur effect for the background.
            backgroundColor: UIColor(hex: "#051123"),  // Custom background color using the hex extension.
            icon: UIImage(named: "munch.png"), // Custom icon for the shield.
            title: ShieldConfiguration.Label(text: title, color: .white), // Title label with custom text and color.
            subtitle: ShieldConfiguration.Label(text: body, color: .white), // Subtitle label with custom text and color.
            primaryButtonLabel: ShieldConfiguration.Label(text: "Close", color: UIColor.black), // Primary button label with custom text and color.
            primaryButtonBackgroundColor: .white, // Background color for the primary button.
            secondaryButtonLabel: nil) // No secondary button label provided.
    }
    
    // Customizes the shield configuration for an application that belongs to a specific category.
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for applications shielded because of their category.
        ShieldConfiguration()
    }
    
    // Customizes the shield configuration for a specific web domain.
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.
        ShieldConfiguration()
    }
    
    // Customizes the shield configuration for a web domain that belongs to a specific category.
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
        ShieldConfiguration()
    }
}
