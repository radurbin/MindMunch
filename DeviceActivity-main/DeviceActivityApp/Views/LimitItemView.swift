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
    @State private var isShowingQuiz = false

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
                        quizViewModel.questionAnswered = false // Reset question answered state
                        isShowingQuiz = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.trailing, 10)
                }
            }
            if confirmLimitID == limit.id {
                if let result = quizViewModel.answerResult {
                    Text(result)
                        .font(.headline)
                        .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                        .padding()
                    if result.starts(with: "Incorrect") {
                        Text("The correct answer was: \(quizViewModel.currentQuestion?.definition ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 5)
                        Button(action: {
                            quizViewModel.prepareQuestion() // Show another question after incorrect answer
                            quizViewModel.answerResult = nil // Reset the result to display the new question
                            quizViewModel.questionAnswered = false // Reset question answered state
                        }) {
                            Text("Next Question")
                                .padding()
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }
                }
                if quizViewModel.answerResult?.starts(with: "Correct") == true {
                    Button(action: {
                        if let id = confirmLimitID {
                            viewModel.extendAppLimit(for: id, by: 15)
                            confirmLimitID = nil
                            quizViewModel.answerResult = nil
                            quizViewModel.questionAnswered = false // Reset question answered state
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
        .sheet(isPresented: $isShowingQuiz) {
            QuizPopupView(quizViewModel: quizViewModel, isShowingQuiz: $isShowingQuiz, showQuestion: $showQuestion)
        }
    }
}

struct QuizPopupView: View {
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var isShowingQuiz: Bool
    @Binding var showQuestion: Bool

    var body: some View {
        VStack {
            if let question = quizViewModel.currentQuestion {
                Text(question.term)
                    .padding(.top, 5)
                VStack {
                    ForEach(quizViewModel.options.indices, id: \.self) { index in
                        let option = quizViewModel.options[index]
                        Button(action: {
                            if quizViewModel.questionAnswered {
                                return
                            }
                            print("Selected answer: \(option)") // Log the selected answer
                            quizViewModel.checkAnswer(option)
                            if quizViewModel.answerResult?.starts(with: "Correct") == true {
                                showQuestion = false // Hide question after correct answer
                                isShowingQuiz = false
                            }
                        }) {
                            Text(option)
                                .padding()
                                .frame(maxWidth: .infinity) // Make the button full-width
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 2) // Adjust padding to ensure buttons don't overlap
                    }
                }
            }
            if let result = quizViewModel.answerResult {
                Text(result)
                    .font(.headline)
                    .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                    .padding()
                if result.starts(with: "Incorrect") {
                    Text("The correct answer was: \(quizViewModel.currentQuestion?.definition ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    Button(action: {
                        quizViewModel.prepareQuestion() // Show another question after incorrect answer
                        quizViewModel.answerResult = nil // Reset the result to display the new question
                        quizViewModel.questionAnswered = false // Reset question answered state
                    }) {
                        Text("Next Question")
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 5)
                }
            }
        }
        .padding()
    }
}
