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
    @State private var isAddLimitPresented = false
    
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
                
                Section(header: Text("App Limits")) {
                    ForEach(viewModel.appLimits) { limit in
                        VStack(alignment: .leading) {
                            Text("Hours: \(limit.hours), Minutes: \(limit.minutes)")
                                .font(.headline)
                            Text("Remaining Time: \(formatTime(limit.remainingTime))")
                                .font(.subheadline)
                            ForEach(Array(limit.selection.applicationTokens), id: \.self) { token in
                                Label(token)
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                isAddLimitPresented = true
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.purple)
            }
            .padding()
            .sheet(isPresented: $isAddLimitPresented) {
                AddLimitView(isPresented: $isAddLimitPresented, limitsViewModel: viewModel)
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        let seconds = Int(time) % 60
        return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
    }
}

struct LimitsView_Previews: PreviewProvider {
    static var previews: some View {
        LimitsView()
    }
}
