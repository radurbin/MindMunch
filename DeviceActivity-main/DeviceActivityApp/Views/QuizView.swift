//
//  QuizView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizletViewModel()
    @State private var newStudySetURL = ""
    @State private var newStudySetName = ""
    @State private var isAddingStudySet = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack {
                    if isAddingStudySet {
                        TextField("Study Set Name", text: $newStudySetName)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .foregroundColor(.black)
                        TextField("Paste Quizlet set URL here", text: $newStudySetURL)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .foregroundColor(.black)
                        Button(action: {
                            viewModel.addStudySet(url: newStudySetURL, name: newStudySetName) { success in
                                if success {
                                    isAddingStudySet = false
                                    newStudySetURL = ""
                                    newStudySetName = ""
                                } else {
                                    // Handle error
                                }
                            }
                        }) {
                            Text("Save Study Set")
                                .padding()
                                .background(Color(hex: "#3A506B"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    } else {
                        Button(action: {
                            isAddingStudySet = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding()
                                .background(Color(hex: "#3A506B"))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }

                    ForEach(viewModel.studySets.indices, id: \.self) { index in
                        let studySet = viewModel.studySets[index]
                        HStack {
                            VStack(alignment: .leading) {
                                Text(studySet.name)
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                                Text(studySet.url)
                                    .font(.subheadline)
                                    .foregroundColor(Color(hex: "#FFFFFF"))
                            }
                            Spacer()
                            if viewModel.activeStudySet?.id == studySet.id {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        .padding()
                        .background(Color(hex: "#3A506B"))
                        .cornerRadius(8)
                        .onTapGesture {
                            viewModel.setActiveStudySet(studySet)
                        }
                        .onLongPressGesture {
                            viewModel.deleteStudySet(at: index)
                        }
                    }
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }
                }
                .padding()
                .onAppear {
                    print("Study Sets in UserDefaults: \(UserDefaults.standard.array(forKey: "studySets") ?? [])")
                    print("Active Study Set: \(UserDefaults.standard.dictionary(forKey: "activeStudySet") ?? [:])")
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

struct StudySetView: View {
    var studySet: StudySet
    var isActive: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack {
            Text(studySet.name)
                .font(.headline)
                .foregroundColor(isActive ? .green : .white)
                .padding()
                .background(isActive ? Color(hex: "#3A506B") : Color(hex: "#1C2541"))
                .cornerRadius(8)
                .onTapGesture {
                    onSelect()
                }
            Spacer()
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

struct StudySet: Codable, Identifiable {
    var id = UUID()
    var name: String
    var url: String
    var flashcards: [Flashcard]
}
