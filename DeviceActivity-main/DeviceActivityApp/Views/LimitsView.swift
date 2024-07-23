//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI
import FamilyControls

struct LimitsView: View {
    @StateObject private var viewModel = LimitsViewModel()
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack {
            Text("Screen Time Limits")
                .font(.largeTitle)
                .padding()
            Text("This is the placeholder for setting screen time limits.")
                .font(.title2)
                .padding()
            
            Button(action: {
                isPickerPresented = true
            }) {
                Text("Select apps to limit")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.activitySelection)
            
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
