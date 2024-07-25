//
//  AddLimitView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/24/24.
//

import SwiftUI
import FamilyControls

struct AddLimitView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var activitySelection = FamilyActivitySelection()
    @ObservedObject var viewModel: LimitsViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                FamilyActivityPicker(selection: $activitySelection)
                    .padding()
                
                Picker("Hours", selection: $selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) hours").tag(hour)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("Minutes", selection: $selectedMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute) minutes").tag(minute)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Button("Save") {
                    viewModel.addAppLimit(selection: activitySelection, hours: selectedHours, minutes: selectedMinutes)
                    presentationMode.wrappedValue.dismiss()
                }.padding()
                
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }.padding()
            }
            .navigationTitle("New Limit")
        }
    }
}
