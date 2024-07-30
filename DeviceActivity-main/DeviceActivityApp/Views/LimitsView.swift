//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct LimitsView: View {
    @StateObject var viewModel = LimitsViewModel()
    @StateObject private var quizViewModel = QuizletViewModel()
    @State private var isPresentingAddLimitView = false
    @State private var confirmLimitID: UUID? = nil
    @State private var showQuestion: Bool = false
    @State private var timer: Timer?

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                List {
                    ForEach(viewModel.appLimits) { limit in
                        LimitItemView(limit: limit, quizViewModel: quizViewModel, confirmLimitID: $confirmLimitID, showQuestion: $showQuestion, viewModel: viewModel)
                            .listRowBackground(Color.clear) // Ensure transparent background for rows
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            viewModel.deleteAppLimit(at: index)
                        }
                    }
                }
                .listStyle(PlainListStyle()) // Set the list style to plain
                .background(Color.clear) // Ensure the list background is clear
                .navigationTitle("Limits")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isPresentingAddLimitView = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAddLimitView) {
                    AddLimitView(viewModel: viewModel)
                }
                .onAppear {
                    startTimer()
                }
                .onDisappear {
                    stopTimer()
                }
            }
            .background(Color.clear) // Ensure the overall background is clear
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            viewModel.objectWillChange.send()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
