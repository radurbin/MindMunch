//
//  Loading.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// A SwiftUI view that displays a loading screen with customizable text and scale.
struct Loading: View {
    
    // The text to be displayed below the loading spinner.
    private let text: String
    
    // The scale factor for the loading spinner and text. Default value is 1.5.
    private let scale: Double
    
    // Initializer for the Loading view, allowing for customization of the displayed text and scale factor.
    init(text: String, scale: Double = 1.5) {
        self.text = text
        self.scale = scale
    }
    
    // The body of the view, which contains a loading spinner with a background gradient.
    var body: some View {
        ZStack {
            // Background gradient that covers the entire screen.
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            // A vertical stack that holds the progress view (spinner) and the text.
            VStack {
                ProgressView {
                    Text(text) // The text to be displayed below the spinner.
                }
                .foregroundColor(.white)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .font(.title3)
                .controlSize(.large)
                .scaleEffect(scale) // Applies the specified scale to the spinner and text.
                .foregroundColor(.white)
            }
        }
    }
}

// A preview provider for the Loading view, which helps visualize the view in Xcode's canvas.
struct Loading_Previews: PreviewProvider {
    static var previews: some View {
        Loading(text: "please wait...") // Provides a sample loading view with default text.
    }
}
