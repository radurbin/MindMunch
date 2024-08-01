//
//  QuizView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

// QuizView.swift
import SwiftUI

struct StudySet: Identifiable, Codable {
    let id: UUID
    let name: String
    let url: String
}

struct QuizView: View {
    @StateObject private var viewModel = QuizletViewModel()
    @State private var newStudySetName = ""
    @State private var newStudySetURL = ""
    @State private var isAddingStudySet = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    Button(action: {
                        isAddingStudySet = true
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Study Set")
                        }
                        .padding()
                        .background(Color(hex: "#3A506B"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()

                    ForEach(viewModel.studySets) { studySet in
                        StudySetView(studySet: studySet, isActive: viewModel.activeStudySet?.id == studySet.id) {
                            viewModel.setActiveStudySet(studySet)
                        } onDelete: {
                            viewModel.deleteStudySet(studySet)
                        }
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
            .sheet(isPresented: $isAddingStudySet) {
                VStack {
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
                        viewModel.addStudySet(name: newStudySetName, url: newStudySetURL)
                        newStudySetName = ""
                        newStudySetURL = ""
                        isAddingStudySet = false
                    }) {
                        Text("Save")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: {
                        isAddingStudySet = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
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

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
