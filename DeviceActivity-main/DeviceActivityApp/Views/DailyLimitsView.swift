//
//  DailyLimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/31/24.
//

import SwiftUI
import FamilyControls

struct DailyLimitsView: View {
    @StateObject private var viewModel = DailyLimitsViewModel()
    @State private var selectedHours = 0
    @State private var selectedMinutes = 0
    @State private var activitySelection = FamilyActivitySelection()
    
    var body: some View {
        NavigationView {
            VStack {
                FamilyActivityPicker(selection: $activitySelection)
                    .padding()
                
                HStack {
                    Text("Hours")
                    Picker("", selection: $selectedHours) {
                        ForEach(0..<24) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .labelsHidden()
                }
                
                HStack {
                    Text("Minutes")
                    Picker("", selection: $selectedMinutes) {
                        ForEach(0..<60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .labelsHidden()
                }
                
                Button(action: {
                    viewModel.addDailyLimit(selection: activitySelection, hours: selectedHours, minutes: selectedMinutes)
                }) {
                    Text("Add Limit")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                List {
                    ForEach(viewModel.dailyLimits) { limit in
                        HStack {
                            Text("App: \(limit.selection.applicationTokens.count)")
                            Text("Time: \(limit.hours)h \(limit.minutes)m")
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deleteDailyLimit(at: index)
                        }
                    }
                }
            }
            .navigationTitle("Daily Limits")
            .padding()
            .onAppear {
                printRemainingTimes()
            }
        }
    }
    
    private func printRemainingTimes() {
        viewModel.loadDailyLimits()
        for limit in viewModel.dailyLimits {
            let remainingTime = limit.remainingTime
            let hours = Int(remainingTime) / 3600
            let minutes = (Int(remainingTime) % 3600) / 60
            let seconds = Int(remainingTime) % 60
            print("Remaining time for \(limit.selection.applicationTokens): \(hours)h \(minutes)m \(seconds)s")
        }
    }
}
