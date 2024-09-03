//
//  LimitsView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

// The main view for managing app limits within the app. It displays a list of app limits and allows the user to add, edit, or delete limits.
struct LimitsView: View {
    // State objects to hold the view models that manage the logic for the limits and quiz functionalities.
    @StateObject var viewModel = LimitsViewModel()
    @StateObject private var quizViewModel = QuizletViewModel()
    
    // State properties to manage the display of the Add Limit view, confirmation dialogs, and question prompts.
    @State private var isPresentingAddLimitView = false
    @State private var confirmLimitID: UUID? = nil
    @State private var showQuestion: Bool = false
    @State private var timer: Timer?

    // The body of the view, which contains the user interface.
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient that covers the entire screen.
                LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                // List of app limits managed by the view model.
                List {
                    ForEach(viewModel.appLimits) { limit in
                        LimitItemView(
                            limit: limit,
                            quizViewModel: quizViewModel,
                            confirmLimitID: $confirmLimitID,
                            showQuestion: $showQuestion,
                            viewModel: viewModel
                        )
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
                        // Button to present the Add Limit view.
                        Button(action: {
                            isPresentingAddLimitView = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                        }
                    }
                }
                // Sheet to display the Add Limit view.
                .sheet(isPresented: $isPresentingAddLimitView) {
                    AddLimitView(viewModel: viewModel)
                }
                // Start the timer when the view appears.
                .onAppear {
                    startTimer()
                }
                // Stop the timer when the view disappears.
                .onDisappear {
                    stopTimer()
                }
            }
            .background(Color.clear) // Ensure the overall background is clear
        }
        // Set the color scheme to dark mode for this view.
        .environment(\.colorScheme, .dark)
    }

    // Starts a timer that triggers the view model to update every second.
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            viewModel.objectWillChange.send()
        }
    }

    // Stops the timer if it is running.
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
