//
//  QuizView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

struct QuizView: View {
    @StateObject private var viewModel = QuizletViewModel()
    @State private var newStudySetURL: String = ""
    @State private var newStudySetName: String = ""
    @State private var showAddStudySetSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack {
                    Text("Study Sets")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddStudySetSheet = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                    
                    ForEach(viewModel.studySets) { studySet in
                        VStack {
                            HStack {
                                Text(studySet.name)
                                    .foregroundColor(.white)
                                    .padding()
                                Spacer()
                                if viewModel.activeStudySet?.id == studySet.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .padding()
                                }
                            }
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#1C2541")))
                            .onTapGesture {
                                viewModel.setActiveStudySet(studySet)
                            }
                            .onLongPressGesture {
                                viewModel.deleteStudySet(at: viewModel.studySets.firstIndex(where: { $0.id == studySet.id })!)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 5)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .sheet(isPresented: $showAddStudySetSheet) {
                VStack {
                    AddStudySetAlertView(url: $newStudySetURL, name: $newStudySetName)
                    
                    Button(action: {
                        viewModel.addStudySet(url: newStudySetURL, name: newStudySetName) { success in
                            if !success {
                                print("Failed to add study set")
                            } else {
                                showAddStudySetSheet = false
                                newStudySetURL = ""
                                newStudySetName = ""
                            }
                        }
                    }) {
                        Text("Save")
                            .padding()
                            .background(Color(hex: "#3A506B"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    
                    Button(action: {
                        showAddStudySetSheet = false
                    }) {
                        Text("Cancel")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.bottom)
                }
                .padding()
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

struct StudySet: Identifiable, Codable {
    var id = UUID()
    var name: String
    var url: String
    var flashcards: [Flashcard] = []
}

struct AddStudySetAlertView: View {
    @Binding var url: String
    @Binding var name: String
    
    var body: some View {
        VStack {
            TextField("Enter Study Set URL", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
            
            TextField("Enter Study Set Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
        }
        .padding()
    }
}
