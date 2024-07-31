//
//  LimitItemView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/30/24.
//

import SwiftUI
import ManagedSettings

struct LimitItemView: View {
    var limit: AppLimit
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var confirmLimitID: UUID?
    @Binding var showQuestion: Bool
    @ObservedObject var viewModel: LimitsViewModel
    @State private var isShowingQuiz = false

    var body: some View {
        VStack(alignment: .leading) {
            // Display the app tokens in a list
            VStack(alignment: .leading, spacing: 5) {
                           ForEach(Array(limit.selection.applicationTokens), id: \.self) { appToken in
                               Label(appToken) // Display the app token
                                   .font(.headline)
                                   .foregroundColor(Color(hex: "#FFFFFF"))
                           }
                       }
            
            VStack(alignment: .leading) {
                Text("Limit: \(limit.hours)h \(limit.minutes)m")
                    .foregroundColor(Color(hex: "#6C757D"))
                Text("Remaining: \(Int(limit.remainingTime) / 3600)h \(Int(limit.remainingTime) % 3600 / 60)m \(Int(limit.remainingTime) % 60)s")
                    .foregroundColor(Color(hex: "#6C757D"))
            }
            .padding(.leading, 4)
            .padding(.bottom, 10)
            
            HStack {
                Spacer()
                if !(quizViewModel.correctAnswersInSession >= 3 && confirmLimitID == limit.id) {
                    Button("Add 15 minutes") {
                        confirmLimitID = limit.id
                        showQuestion = true
                        quizViewModel.prepareQuestion()
                        quizViewModel.answerResult = nil // Reset answer result
                        quizViewModel.questionAnswered = false // Reset question answered state
                        quizViewModel.correctAnswersInSession = 0 // Reset session correct answers
                        isShowingQuiz = true
                    }
                    .padding()
                    .background(Color(hex: "#3A506B"))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            if confirmLimitID == limit.id {
                if quizViewModel.correctAnswersInSession >= 3 {
                    Button(action: {
                        if let id = confirmLimitID {
                            viewModel.extendAppLimit(for: id, by: 15)
                            confirmLimitID = nil
                            quizViewModel.answerResult = nil
                            quizViewModel.questionAnswered = false // Reset question answered state
                            quizViewModel.correctAnswersInSession = 0 // Reset session correct answers
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
                } else if let result = quizViewModel.answerResult {
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
                    if result.starts(with: "Correct") {
                        Button(action: {
                            if quizViewModel.correctAnswersInSession >= 3 {
                                showQuestion = false
                                isShowingQuiz = false
                            } else {
                                quizViewModel.prepareQuestion() // Show another question after correct answer
                                quizViewModel.answerResult = nil // Reset the result to display the new question
                                quizViewModel.questionAnswered = false // Reset question answered state
                            }
                        }) {
                            Text(quizViewModel.correctAnswersInSession >= 3 ? "Return to Limits" : "Next Question")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingQuiz) {
            QuizPopupView(quizViewModel: quizViewModel, isShowingQuiz: $isShowingQuiz, showQuestion: $showQuestion)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(hex: "#1C2541"))
                .shadow(radius: 5)
        )
        .environment(\.colorScheme, .dark)
    }
}


struct QuizPopupView: View {
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var isShowingQuiz: Bool
    @Binding var showQuestion: Bool

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                if let question = quizViewModel.currentQuestion {
                    Text(question.term)
                        .padding(.top, 5)
                        .foregroundColor(Color(hex: "#FFFFFF"))
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
                                    quizViewModel.correctAnswersInSession += 1
                                }
                            }) {
                                Text(option)
                                    .padding()
                                    .frame(maxWidth: .infinity) // Make the button full-width
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                            }
                            .padding(.vertical, 2) // Adjust padding to ensure buttons don't overlap
                        }
                    }
                    Text("Correct Answers: \(quizViewModel.correctAnswersInSession)/3")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .padding(.top, 10)
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
                    if result.starts(with: "Correct") {
                        Button(action: {
                            if quizViewModel.correctAnswersInSession >= 3 {
                                showQuestion = false
                                isShowingQuiz = false
                            } else {
                                quizViewModel.prepareQuestion() // Show another question after correct answer
                                quizViewModel.answerResult = nil // Reset the result to display the new question
                                quizViewModel.questionAnswered = false // Reset question answered state
                            }
                        }) {
                            Text(quizViewModel.correctAnswersInSession >= 3 ? "Return to Limits" : "Next Question")
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }
                }
            }
            .padding()
            .background(Color(hex: "#1C2541").opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 10)
        }
        .environment(\.colorScheme, .dark)
    }
}
