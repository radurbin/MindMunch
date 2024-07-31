//
//  QuizView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizletViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    TextField("Paste Quizlet set URL here", text: $viewModel.quizletURL)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .foregroundColor(.black)
                    
                    Button(action: {
                        viewModel.fetchFlashcards(from: viewModel.quizletURL)
                    }) {
                        Text("Fetch Flashcards")
                            .padding()
                            .background(Color(hex: "#3A506B"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                    
                    if let question = viewModel.currentQuestion {
                        Text("Question \(viewModel.questionNumber)")
                            .font(.headline)
                            .foregroundColor(Color(hex: "#FFFFFF"))
                            .padding()
                        
                        Text("\(question.term)")
                            .padding()
                            .font(.title2)
                            .foregroundColor(Color(hex: "#FFFFFF"))
                        
                        ForEach(viewModel.options, id: \.self) { option in
                            Button(action: {
                                viewModel.checkAnswer(option)
                            }) {
                                Text(option)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                            }
                        }
                        
                        if let result = viewModel.answerResult {
                            Text(result)
                                .font(.headline)
                                .foregroundColor(result.starts(with: "Correct") ? .green : .red)
                                .padding()
                        }
                        
                        Text("Correct Answers: \(viewModel.correctAnswers)")
                            .padding()
                            .foregroundColor(Color(hex: "#FFFFFF"))
                        
                        Text("Incorrect Answers: \(viewModel.incorrectAnswers)")
                            .padding()
                            .foregroundColor(Color(hex: "#FFFFFF"))
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Spacer()
                }
                .padding()
                .onTapGesture {
                    self.hideKeyboard()
                }
            }
        }
        .environment(\.colorScheme, .dark)
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

