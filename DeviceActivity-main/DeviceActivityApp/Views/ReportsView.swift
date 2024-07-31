//
//  ReportsView.swift
//  DeviceActivityApp
//
//  Created by Pedro Somensi on 06/08/23.
//  Expanded by Riley Durbin on 07/23/24.
//

import SwiftUI

struct ReportsView: View {
    
    var body: some View {
        ZStack {
            Loading(text: "loading...",
                    scale: 1)
            DeviceActivityReporterAdapter()
        }
        .environment(\.colorScheme, .dark)
    }
    
}

struct ReportsView_Previews: PreviewProvider {
    static var previews: some View {
        
        ReportsView()
    }
}
