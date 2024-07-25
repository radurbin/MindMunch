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
                    .background(Color(UIColor.systemGroupedBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("Hours")
                    Picker("", selection: $selectedHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .labelsHidden()
                }
                
                HStack {
                    Text("Minutes")
                    Picker("", selection: $selectedMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .labelsHidden()
                }
                
                Button(action: {
                    viewModel.addAppLimit(selection: activitySelection, hours: selectedHours, minutes: selectedMinutes)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
            .navigationTitle("New Limit")
            .padding()
        }
    }
}
