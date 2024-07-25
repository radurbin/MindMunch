//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct LimitsView: View {
    @StateObject var viewModel = LimitsViewModel()
    @State private var isPresentingAddLimitView = false
    @State private var confirmLimitID: UUID? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.appLimits) { limit in
                    VStack(alignment: .leading) {
                        HStack {
                            if let appToken = limit.selection.applicationTokens.first {
                                Image(systemName: "app.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .padding()
                                VStack(alignment: .leading) {
                                    Label(appToken) // Replace with actual app name
                                        .font(.headline)
                                    Text("Limit: \(limit.hours)h \(limit.minutes)m")
                                    Text("Remaining: \(Int(limit.remainingTime) / 3600)h \(Int(limit.remainingTime) % 3600 / 60)m")
                                }
                            }
                            Spacer()
                            Button("Add 15 minutes") {
                                confirmLimitID = limit.id
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        if confirmLimitID == limit.id {
                            Text("Dummy text: Are you sure you want to add 15 minutes?")
                                .padding(.top, 5)
                            HStack {
                                Button("Confirm") {
                                    if let id = confirmLimitID {
                                        viewModel.extendAppLimit(for: id, by: 15)
                                        confirmLimitID = nil
                                    }
                                }
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                Spacer()
                                Button("Cancel") {
                                    confirmLimitID = nil
                                }
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .padding(.top, 5)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        viewModel.deleteAppLimit(at: index)
                    }
                }
            }
            .navigationTitle("Limits")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAddLimitView = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddLimitView) {
                AddLimitView(viewModel: viewModel)
            }
        }
    }
}
