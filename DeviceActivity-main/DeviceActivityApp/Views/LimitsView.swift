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
    @State private var isAddButtonDisabled: Bool = false
    @State private var isConfirmButtonDisabled: Bool = false

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
                                isAddButtonDisabled = true
                            }
                            .padding()
                            .background(isAddButtonDisabled ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.trailing, 10)
                            .disabled(isAddButtonDisabled)
                        }
                        if confirmLimitID == limit.id {
                            Text("Dummy text: Are you sure you want to add 15 minutes?")
                                .padding(.top, 5)
                            HStack {
                                Button(action: {
                                    if let id = confirmLimitID {
                                        viewModel.extendAppLimit(for: id, by: 15)
                                        confirmLimitID = nil
                                        isAddButtonDisabled = false
                                    }
                                }) {
                                    Text("Confirm")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(isConfirmButtonDisabled ? Color.gray : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.trailing, 5)
                                .disabled(isConfirmButtonDisabled)

                                Button(action: {
                                    confirmLimitID = nil
                                    isConfirmButtonDisabled = true
                                    isAddButtonDisabled = false
                                }) {
                                    Text("Cancel")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
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
