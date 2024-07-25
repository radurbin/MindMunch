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
                            if confirmLimitID != limit.id {
                                Button("Add 15 minutes") {
                                    confirmLimitID = limit.id
                                    showQuestion = true
                                    quizViewModel.prepareQuestion()
                                }
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.trailing, 10)
                            }
                        }
                        if confirmLimitID == limit.id {
                            if showQuestion, let question = quizViewModel.currentQuestion {
                                Text(question.term)
                                    .padding(.top, 5)
                                ForEach(quizViewModel.options, id: \.self) { option in
                                    Button(action: {
                                        quizViewModel.checkAnswer(option)
                                        if quizViewModel.answerResult?.starts(with: "Correct") == true || quizViewModel.answerResult?.starts(with: "Incorrect") == true {
                                            showQuestion = false
                                        }
                                    }) {
                                        Text(option)
                                            .padding()
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(8)
                                    }
                                }
                                if let result = quizViewModel.answerResult {
                                    Text(result)
                                        .font(.headline)
                                        .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                                        .padding()
                                }
                            }
                            if !showQuestion {
                                Button(action: {
                                    if let id = confirmLimitID {
                                        viewModel.extendAppLimit(for: id, by: 15)
                                        confirmLimitID = nil
                                    }
                                }) {
                                    Text("Confirm")
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding(.trailing, 5)
                            }
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
