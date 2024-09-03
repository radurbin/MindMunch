//
//  QuizView.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import SwiftUI

// The main view for the Quiz feature, where users can manage their study sets.
struct QuizView: View {
    // StateObject to hold the QuizletViewModel, which manages the data and logic for the quiz.
    @StateObject private var viewModel = QuizletViewModel()
    
    // State properties to hold the new study set URL and name, and to control the display of the sheet.
    @State private var newStudySetURL: String = ""
    @State private var newStudySetName: String = ""
    @State private var showAddStudySetSheet = false

    // The body of the view, defining the user interface.
    var body: some View {
        ZStack {
            // Background gradient that covers the entire screen.
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#0B132B"), Color(hex: "#1C2541")]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            // Scrollable content area.
            ScrollView {
                VStack(alignment: .leading) {
                    // Header section with an image and title.
                    HStack(alignment: .center, spacing: -25) {
                        Image("brain-only")
                            .resizable()
                            .frame(width: 110, height: 110)
                        
                        Text("My Munches")
                            .bold()
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    
                    // Button to add a new study set.
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

                    // Grid of study set boxes.
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.studySets) { studySet in
                            StudySetBoxView(
                                studySet: studySet,
                                isActive: viewModel.activeStudySet?.id == studySet.id,
                                onSelect: {
                                    viewModel.setActiveStudySet(studySet)
                                },
                                onDelete: {
                                    if let index = viewModel.studySets.firstIndex(where: { $0.id == studySet.id }) {
                                        viewModel.deleteStudySet(at: index)
                                    }
                                }
                            )
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
            // Sheet for adding a new study set.
            .sheet(isPresented: $showAddStudySetSheet) {
                VStack {
                    AddStudySetAlertView(url: $newStudySetURL, name: $newStudySetName)

                    // Button to save the new study set.
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

                    // Button to cancel adding a new study set.
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
        // Set the color scheme to dark mode for this view.
        .environment(\.colorScheme, .dark)
    }
}

// A preview provider for the QuizView, useful for visualizing the view in Xcode's canvas.
struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView()
    }
}

// An extension to hide the keyboard programmatically.
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// A model representing a study set, which includes an ID, name, URL, and an array of flashcards.
struct StudySet: Identifiable, Codable {
    var id = UUID()
    var name: String
    var url: String
    var flashcards: [Flashcard] = []
}

// A view for the alert that allows users to add a new study set.
struct AddStudySetAlertView: View {
    @Binding var url: String
    @Binding var name: String
    
    var body: some View {
        VStack {
            // Text field for entering the study set URL.
            TextField("Enter Study Set URL", text: $url)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
            
            // Text field for entering the study set name.
            TextField("Enter Study Set Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
        }
        .padding()
    }
}

// A view for displaying a study set in a horizontal list.
struct StudySetView: View {
    var studySet: StudySet
    var isActive: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack {
            // Displays the study set name.
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
            // Button to delete the study set.
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .padding()
        }
        .padding(.horizontal)
    }
}

// A view for displaying a study set as a box in a grid.
struct StudySetBoxView: View {
    var studySet: StudySet
    var isActive: Bool
    var onSelect: () -> Void
    var onDelete: () -> Void

    var body: some View {
        ZStack {
            // Background for the study set box.
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(height: 150)
                .shadow(radius: 5)
                .onTapGesture {
                    onSelect()
                }
                .onLongPressGesture {
                    onDelete()
                }
            
            VStack {
                // Top section with the Quizlet logo and active indicator.
                HStack {
                    Image("quizlet-logo") // Ensure this image is added to your assets
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(5)
                    
                    Spacer()
                    
                    // Displays a green circle if the study set is active.
                    if isActive {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 15, height: 15)
                            .padding(5)
                    }
                }
                
                Spacer()
                
                // Displays the study set name.
                Text(studySet.name)
                    .font(.headline)
                    .foregroundColor(Color(hex: "#1C2541"))
                    .padding(.horizontal)
                    .padding(.bottom, 5)
                
                Spacer()
            }
            .padding()
        }
    }
}
