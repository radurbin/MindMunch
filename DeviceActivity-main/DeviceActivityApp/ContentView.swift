//
//  ContentView.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// The main content view for the app, which serves as a simple placeholder.
struct ContentView: View {
    var body: some View {
        // A vertical stack that centers its contents.
        VStack {
            // A system image of a globe, scaled to a large size and colored with the accent color.
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            
            // A text label displaying "Hello, world!".
            Text("Hello, world!")
        }
        // Adds padding around the VStack to provide spacing.
        .padding()
        // Forces the color scheme of this view to dark mode.
        .environment(\.colorScheme, .dark)
    }
}

// A preview provider for the ContentView, useful for visualizing the view in Xcode's canvas.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
