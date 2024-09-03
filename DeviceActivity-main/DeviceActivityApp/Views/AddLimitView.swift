//
//  AddLimitView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/24/24.
//

import SwiftUI
import FamilyControls

// A view for adding a new app limit. The user can select apps or categories, specify the duration, and save the limit.
struct AddLimitView: View {
    // Environment variable to manage the presentation mode, used for dismissing the view.
    @Environment(\.presentationMode) var presentationMode
    
    // State variables to hold the selected hours, minutes, and activity selection for the new limit.
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var activitySelection = FamilyActivitySelection()
    
    // Observed object to interact with the LimitsViewModel, which handles adding the new limit.
    @ObservedObject var viewModel: LimitsViewModel
    
    // The body of the view, which contains the user interface for adding a new limit.
    var body: some View {
        NavigationView {
            VStack {
                // Picker to select apps or categories to limit.
                FamilyActivityPicker(selection: $activitySelection)
                    .padding()
                    .background(Color(UIColor.systemGroupedBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding(.bottom, 20)
                
                // Picker to select the number of hours for the limit.
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
                
                // Picker to select the number of minutes for the limit.
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
                
                // Button to save the new limit and dismiss the view.
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
                
                // Button to cancel the action and dismiss the view.
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
        // Set the color scheme to dark mode for this view.
        .environment(\.colorScheme, .dark)
    }
}
