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
        VStack {
            TextField("Paste Quizlet set URL here", text: $viewModel.quizletURL)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                viewModel.fetchFlashcards(from: viewModel.quizletURL)
            }) {
                Text("Fetch Flashcards")
                    .padding()
                    .background(Color.blue)
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
                    .padding()
                
                Text("\(question.term)")  // Changed line
                    .padding()
                    .font(.title2) // Optional: adjust the font size
                
                ForEach(viewModel.options, id: \.self) { option in
                    Button(action: {
                        viewModel.checkAnswer(option)
                    }) {
                        Text(option)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
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
                
                Text("Incorrect Answers: \(viewModel.incorrectAnswers)")
                    .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}
