//
//  QuizletViewModel.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import Foundation

class QuizletViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentQuestion: Flashcard?
    @Published var options: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var answerResult: String?
    @Published var questionNumber = 1
    @Published var correctAnswers = 0
    @Published var incorrectAnswers = 0
    @Published var correctAnswersInSession = 0 // Track correct answers in the current session
    @Published var quizletURL: String {
        didSet {
            saveURLToUserDefaults()
            fetchFlashcardsIfNeeded()
        }
    }
    @Published var questionAnswered = false
    @Published var studySets: [StudySet] = []
    @Published var activeStudySet: StudySet?

    private let baseUrl = "https://quizlet.com/webapi/3.4/studiable-item-documents"
    private var setId = ""
    private let userDefaultsKey = "quizletFlashcards"
    private let lastUpdateKey = "lastUpdateTimestamp"
    
    init() {
        self.quizletURL = UserDefaults.standard.string(forKey: "quizletURL") ?? ""
        if !quizletURL.isEmpty {
            fetchFlashcardsIfNeeded()
        }
        loadStudySets()
        loadActiveStudySet()
        printStudySets()
    }

    private func fetchFlashcardsIfNeeded() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey) {
            if let decodedFlashcards = try? JSONDecoder().decode([Flashcard].self, from: savedData) {
                self.flashcards = decodedFlashcards
                prepareQuestion()
                return
            }
        }
        fetchFlashcards(from: quizletURL)
    }

    func fetchFlashcards(from url: String) {
        guard let extractedId = extractID(from: url) else {
            self.errorMessage = "Invalid URL"
            return
        }
        self.setId = extractedId
        saveURLToUserDefaults() // Save URL to UserDefaults
        
        isLoading = true
        self.flashcards = [] // Clear existing flashcards before fetching new ones
        let initialUrlString = "\(baseUrl)?filters[studiableContainerId]=\(setId)&filters[studiableContainerType]=1&perPage=500&page=1"
        
        print("Initial API URL: \(initialUrlString)")
        
        fetchPage(urlString: initialUrlString)
    }

    private func fetchPage(urlString: String) {
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }
        
        print("Fetching URL: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    print("Received data: \(apiResponse)")
                    self.processFlashcards(apiResponse)
                    if let paging = apiResponse.responses.first?.paging, let token = paging.token {
                        if paging.total > paging.perPage * paging.page {
                            let nextPageUrl = "\(self.baseUrl)?filters[studiableContainerId]=\(self.setId)&filters[studiableContainerType]=1&perPage=\(paging.perPage)&page=\(paging.page + 1)&pagingToken=\(token)"
                            self.fetchPage(urlString: nextPageUrl)
                        } else {
                            self.isLoading = false
                            self.prepareQuestion()
                        }
                    } else {
                        self.isLoading = false
                        self.prepareQuestion()
                    }
                    self.saveFlashcardsToUserDefaults()
                }
            } catch {
                DispatchQueue.main.async {
                    print("Decoding error: \(error)")
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                        print("JSON response: \(json)")
                    }
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }.resume()
    }

    private func extractID(from url: String) -> String? {
        let pattern = "quizlet.com/(\\d+)/"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = url as NSString
        let results = regex?.matches(in: url, options: [], range: NSRange(location: 0, length: nsString.length))
        
        if let match = results?.first, let range = Range(match.range(at: 1), in: url) {
            return String(url[range])
        }
        
        return nil
    }

    private func processFlashcards(_ apiResponse: APIResponse) {
        let studiableItems = apiResponse.responses.flatMap { $0.models.studiableItem }
        let newFlashcards = studiableItems.map { item in
            let term = item.cardSides.first { $0.label == "word" }?.media.first?.plainText ?? ""
            let definition = item.cardSides.first { $0.label == "definition" }?.media.first?.plainText ?? ""
            return Flashcard(id: item.id, term: term, definition: definition)
        }
        self.flashcards.append(contentsOf: newFlashcards)
        print("Processed Flashcards: \(self.flashcards.count)") // Debug print
    }


    private func saveFlashcardsToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(self.flashcards) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastUpdateKey)
        }
    }

    func prepareQuestion() {
        loadActiveStudySet()
        guard let activeStudySet = activeStudySet, !activeStudySet.flashcards.isEmpty else { return }
        
        currentQuestion = activeStudySet.flashcards.randomElement()
        if let correctAnswer = currentQuestion?.definition {
            var options = [correctAnswer]
            while options.count < 4 {
                if let randomOption = activeStudySet.flashcards.randomElement()?.definition, !options.contains(randomOption) {
                    options.append(randomOption)
                }
            }
            self.options = options.shuffled()
            self.answerResult = nil
            self.questionAnswered = false
            print("Prepared question: \(currentQuestion?.term ?? "No term") with options: \(self.options)")
        } else {
            print("Failed to prepare question: No correct answer found")
        }
    }

    func checkAnswer(_ selectedAnswer: String) {
        guard !questionAnswered else { return }
        
        if selectedAnswer == currentQuestion?.definition {
            correctAnswers += 1
            answerResult = "Correct!"
        } else {
            incorrectAnswers += 1
            answerResult = "Incorrect! The correct answer was: \(currentQuestion?.definition ?? "")"
        }
        
        questionAnswered = true
    }

    private func saveURLToUserDefaults() {
        UserDefaults.standard.set(quizletURL, forKey: "quizletURL")
    }

    func addStudySet(url: String, name: String, completion: @escaping (Bool) -> Void) {
        guard studySets.count < 3 else {
            errorMessage = "You can only save up to 3 study sets."
            completion(false)
            return
        }
        
        fetchFlashcards(from: url)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            let newStudySet = StudySet(name: name, url: url, flashcards: self.flashcards)
            self.studySets.append(newStudySet)
            self.saveStudySetsToUserDefaults()
            self.printStudySets()
            completion(true)
        }
    }

    func setActiveStudySet(_ studySet: StudySet) {
        activeStudySet = studySet
        saveActiveStudySetToUserDefaults()
        prepareQuestion()
        print("Active Study Set: \(activeStudySet?.name ?? "None") with \(activeStudySet?.flashcards.count ?? 0) flashcards")
    }

    func deleteStudySet(at index: Int) {
        studySets.remove(at: index)
        saveStudySetsToUserDefaults()
        printStudySets()
    }

    private func saveStudySetsToUserDefaults() {
        if let encodedData = try? JSONEncoder().encode(studySets) {
            UserDefaults.standard.set(encodedData, forKey: "studySets")
        }
    }

    private func loadStudySets() {
        if let savedData = UserDefaults.standard.data(forKey: "studySets"),
           let decodedStudySets = try? JSONDecoder().decode([StudySet].self, from: savedData) {
            self.studySets = decodedStudySets
        }
    }

    private func saveActiveStudySetToUserDefaults() {
        if let activeStudySet = activeStudySet,
           let encodedData = try? JSONEncoder().encode(activeStudySet) {
            UserDefaults.standard.set(encodedData, forKey: "activeStudySet")
        }
    }

    func loadActiveStudySet() {
        if let savedData = UserDefaults.standard.data(forKey: "activeStudySet"),
           let decodedStudySet = try? JSONDecoder().decode(StudySet.self, from: savedData) {
            self.activeStudySet = decodedStudySet
            print("Loaded active study set: \(activeStudySet?.name ?? "None")")
        } else {
            print("No active study set found in UserDefaults.")
        }
    }

    private func printStudySets() {
        let studySetsData = UserDefaults.standard.data(forKey: "studySets")
        print("Study Sets in UserDefaults: \(studySetsData?.count ?? 0) bytes")
        
        let activeStudySetData = UserDefaults.standard.data(forKey: "activeStudySet")
        print("Active Study Set: \(activeStudySetData?.count ?? 0) bytes")
    }
}
