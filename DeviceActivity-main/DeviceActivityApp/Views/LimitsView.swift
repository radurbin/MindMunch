//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct LimitsView: View {
    @StateObject private var viewModel = LimitsViewModel()
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack {
            Text("Screen Time Limits")
                .font(.largeTitle)
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
            .padding()
            
            Toggle("Lock/Unlock Apps", isOn: $viewModel.isLocked)
                .padding()
                .toggleStyle(SwitchToggleStyle(tint: .red))
            
            Text("Selected Apps + Categories")
                .font(.title3)
                .padding()
            
            List {
                Section {
                    ForEach(Array(viewModel.activitySelection.applicationTokens), id: \.self) { token in
                        HStack {
                            Label(token)
                                .font(.body)
                        }
                    }
                    ForEach(Array(viewModel.activitySelection.categoryTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                    }
                }
            }
            
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
