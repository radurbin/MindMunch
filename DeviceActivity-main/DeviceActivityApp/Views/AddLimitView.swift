//
//  AddLimitView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/24/24.
//

import SwiftUI
import FamilyControls

struct AddLimitView: View {
    @Binding var isPresented: Bool
    @ObservedObject var limitsViewModel: LimitsViewModel
    @StateObject private var viewModel = AddLimitViewModel()
    @State private var isPickerPresented = false
    
    var body: some View {
        VStack {
            Text("New Limit")
                .font(.largeTitle)
                .padding()
            
            Button(action: {
                isPickerPresented = true
            }) {
                Text("Select Applications")
                    .foregroundColor(.purple)
                    .padding()
            }
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $viewModel.selectedApps)
            .padding()
            
            Text("Time Limit")
                .font(.title2)
                .padding()
            
            HStack {
                Picker("Hours", selection: $viewModel.selectedHours) {
                    ForEach(0..<24) { hour in
                        Text("\(hour) Hours").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 100)
                
                Picker("Minutes", selection: $viewModel.selectedMinutes) {
                    ForEach(0..<60) { minute in
                        Text("\(minute) Minutes").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 100, height: 100)
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                limitsViewModel.addAppLimit(selection: viewModel.selectedApps, hours: viewModel.selectedHours, minutes: viewModel.selectedMinutes)
                isPresented = false
            }) {
                Text("Save")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Button(action: {
                isPresented = false
            }) {
                Text("Cancel")
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct AddLimitView_Previews: PreviewProvider {
    static var previews: some View {
        AddLimitView(isPresented: .constant(true), limitsViewModel: LimitsViewModel())
    }
}
