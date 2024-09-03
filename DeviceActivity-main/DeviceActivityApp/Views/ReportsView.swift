//
//  ReportsView.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

// A SwiftUI view that displays the reports screen, which includes a loading indicator
// and the device activity report.
struct ReportsView: View {
    
    // The body of the view, which contains a ZStack that layers the loading view
    // and the device activity report adapter.
    var body: some View {
        ZStack {
            // Displays a loading view with the text "loading..." while the data is being prepared.
            Loading(text: "loading...", scale: 1)
            
            // Displays the device activity report once the data is ready.
            DeviceActivityReporterAdapter()
        }
        // Sets the color scheme of this view to dark mode.
        .environment(\.colorScheme, .dark)
    }
}

// A preview provider for the ReportsView, useful for visualizing the view in Xcode's canvas.
struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        ReportsView()
    }
}
