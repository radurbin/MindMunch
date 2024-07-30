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
            List {
                ForEach(viewModel.appLimits) { limit in
                    LimitItemView(limit: limit, quizViewModel: quizViewModel, confirmLimitID: $confirmLimitID, showQuestion: $showQuestion, viewModel: viewModel)
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
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
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
