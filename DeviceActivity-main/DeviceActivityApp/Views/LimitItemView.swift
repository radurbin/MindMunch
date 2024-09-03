//
//  LimitItemView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/30/24.
//

import SwiftUI
import ManagedSettings

// A view that represents a single limit item in the list of app limits.
struct LimitItemView: View {
    var limit: AppLimit
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var confirmLimitID: UUID?
    @Binding var showQuestion: Bool
    @ObservedObject var viewModel: LimitsViewModel
    @State private var isShowingQuiz = false

    // The body of the view, defining the user interface for a single limit item.
    var body: some View {
        VStack(alignment: .leading) {
            // Display the app tokens associated with the limit.
            VStack(alignment: .leading, spacing: 5) {
                ForEach(Array(limit.selection.applicationTokens), id: \.self) { appToken in
                    Label(appToken) // Display the app token
                        .font(.headline)
                        .foregroundColor(Color(hex: "#FFFFFF"))
                }
            }

            VStack(alignment: .leading) {
                // Display the configured limit duration.
                Text("Limit: \(limit.hours)h \(limit.minutes)m")
                    .foregroundColor(Color(hex: "#6C757D"))
                
                // Display the remaining time for the limit.
                Text("Remaining: \(Int(limit.remainingTime) / 3600)h \(Int(limit.remainingTime) % 3600 / 60)m \(Int(limit.remainingTime) % 60)s")
                    .foregroundColor(Color(hex: "#6C757D"))
            }
            .padding(.leading, 4)
            .padding(.bottom, 10)

            HStack {
                Spacer()
                // Button to add 15 minutes to the limit after answering quiz questions.
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

            // If the user has successfully answered 3 questions, show the confirm button.
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
                    // Display the result of the answered question.
                    Text(result)
                        .font(.headline)
                        .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                        .padding()
                    
                    // If the answer was incorrect, show the correct answer and a button for the next question.
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

                    // If the answer was correct, provide options to continue or return to the limits list.
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
        // Display the quiz in a popup sheet when the quiz is triggered.
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
        .onAppear {
            quizViewModel.loadActiveStudySet()
            quizViewModel.prepareQuestion()
            print("Active study set loaded in LimitItemView: \(quizViewModel.activeStudySet?.name ?? "None")")
        }
    }
}

// A view that represents the quiz popup, which appears when the user attempts to extend a limit.
struct QuizPopupView: View {
    @StateObject var quizViewModel: QuizletViewModel
    @Binding var isShowingQuiz: Bool
    @Binding var showQuestion: Bool

    var body: some View {
        ZStack {
            // Background gradient for the quiz popup.
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Image("logo") // Ensure this matches the name of your image asset
                    .resizable()
                    .frame(width: 300, height: 300) // Adjust the size as needed
                    .padding(.bottom, -120)
                    .padding(.top, -130)
                
                // Display the current question and answer options.
                if let question = quizViewModel.currentQuestion {
                    Text(question.term)
                        .padding(.top, 5)
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .font(.headline)
                    
                    VStack {
                        // Display the answer options in rows of two.
                        ForEach(quizViewModel.options.chunked(into: 2), id: \.self) { rowOptions in
                            HStack {
                                ForEach(rowOptions, id: \.self) { option in
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
                                            .frame(maxWidth: .infinity, maxHeight: 200)
                                            .background(Color.white)
                                            .cornerRadius(8)
                                            .foregroundColor(Color(hex: "#0B132B"))
                                            .font(.body)
                                            .multilineTextAlignment(.center) // Ensure text is centered
                                    }
                                    .padding(5)
                                }
                            }
                        }
                    }
                    // Display the number of correct answers in the current session.
                    Text("Correct Answers: \(quizViewModel.correctAnswersInSession)/3")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "#FFFFFF"))
                        .padding(.top, 10)
                }

                // Display the result of the user's answer.
                if let result = quizViewModel.answerResult {
                    Text(result)
                        .font(.headline)
                        .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                        .padding()
                    
                    // If the answer was incorrect, provide the correct answer and a button for the next question.
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

                    // If the answer was correct, provide options to continue or return to the limits list.
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

// An extension to the Collection type that allows splitting a collection into chunks of a specified size.
extension Collection {
    func chunked(into size: Int) -> [SubSequence] {
        var chunks: [SubSequence] = []
        var startIndex = self.startIndex
        while startIndex != self.endIndex {
            let endIndex = index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            chunks.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }
        return chunks
    }
}
