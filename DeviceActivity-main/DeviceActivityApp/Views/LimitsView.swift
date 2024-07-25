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
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.appLimits) { limit in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Limit: \(limit.hours)h \(limit.minutes)m")
                                Text("Remaining: \(Int(limit.remainingTime) / 3600)h \(Int(limit.remainingTime) % 3600 / 60)m")
                            }
                            Spacer()
                            Button("Add 15 minutes") {
                                viewModel.extendAppLimit(for: limit.id, by: 15)
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
}
