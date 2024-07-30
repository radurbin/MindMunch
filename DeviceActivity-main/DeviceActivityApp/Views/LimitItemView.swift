//
//  LimitItemView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/30/24.
//

import SwiftUI

struct LimitItemView: View {
    var limit: AppLimit
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var confirmLimitID: UUID?
    @Binding var showQuestion: Bool
    @ObservedObject var viewModel: LimitsViewModel

    var body: some View {
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
                        Text("Remaining: \(Int(limit.remainingTime) / 3600)h \(Int(limit.remainingTime) % 3600 / 60)m \(Int(limit.remainingTime) % 60)s")
                    }
                }
                Spacer()
                if confirmLimitID != limit.id {
                    Button("Add 15 minutes") {
                        confirmLimitID = limit.id
                        showQuestion = true
                        quizViewModel.prepareQuestion()
                        quizViewModel.answerResult = nil // Reset answer result
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
                            showQuestion = false // Hide question after answer
                        }) {
                            Text(option)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
                if let result = quizViewModel.answerResult {
                    Text(result)
                        .font(.headline)
                        .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                        .padding()
                }
                if quizViewModel.answerResult != nil {
                    Button(action: {
                        if let id = confirmLimitID {
                            viewModel.extendAppLimit(for: id, by: 15)
                            confirmLimitID = nil
                            quizViewModel.answerResult = nil
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
}
