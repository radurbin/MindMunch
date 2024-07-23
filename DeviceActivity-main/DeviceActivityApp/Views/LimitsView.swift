//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct LimitsView: View {
    var body: some View {
        VStack {
            Text("Screen Time Limits")
                .font(.largeTitle)
                .padding()
            Text("This is the placeholder for setting screen time limits.")
                .font(.title2)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct LimitsView_Previews: PreviewProvider {
    static var previews: some View {
        LimitsView()
    }
}
