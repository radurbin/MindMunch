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

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.studySets) { studySet in
                            StudySetBoxView(
                                studySet: studySet,
                                isActive: viewModel.activeStudySet?.id == studySet.id,
                                onSelect: {
                                    viewModel.setActiveStudySet(studySet)
                                },
                                onDelete: {
                                    viewModel.deleteStudySet(at: viewModel.studySets.firstIndex(where: { $0.id == studySet.id })!)
                                }
                            )
                        }
                    }
                    .padding()

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

struct StudySetBoxView: View {
    var studySet: StudySet
    var isActive: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 150)
                .shadow(radius: 5)
            
            VStack {
                HStack {
                    Image("quizlet-logo") // Ensure this image is added to your assets
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(5)
                    
                    Spacer()
                    
                    if isActive {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 15, height: 15)
                            .padding(5)
                    }
                }
                
                Spacer()
                
                Text(studySet.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1C2541"))
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding()
            .onTapGesture {
                onSelect()
            }
            .onLongPressGesture {
                onDelete()
            }
        }
    }
}
