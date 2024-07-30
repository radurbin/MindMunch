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
    @Published var quizletURL: String {
        didSet {
            saveURLToUserDefaults()
        }
    }
    @Published var questionAnswered = false
    @Published var correctAnswersInSession = 0 // Track correct answers in the current session
    
    private let baseUrl = "https://quizlet.com/webapi/3.4/studiable-item-documents"
    private var setId = ""
    
    init() {
        self.quizletURL = UserDefaults.standard.string(forKey: "quizletURL") ?? ""
        if !quizletURL.isEmpty {
            fetchFlashcards(from: quizletURL)
        }
    }
    
    func fetchFlashcards(from url: String) {
        guard let extractedId = extractID(from: url) else {
            self.errorMessage = "Invalid URL"
            return
        }
        self.setId = extractedId
        saveURLToUserDefaults() // Save URL to UserDefaults
        
        isLoading = true
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
    }
    
    func prepareQuestion() {
        guard !flashcards.isEmpty else { return }
        
        currentQuestion = flashcards.randomElement()
        if let correctAnswer = currentQuestion?.definition {
            var options = [correctAnswer]
            while options.count < 4 {
                if let randomOption = flashcards.randomElement()?.definition, !options.contains(randomOption) {
                    options.append(randomOption)
                }
            }
            self.options = options.shuffled()
            self.answerResult = nil
            self.questionAnswered = false
        }
    }
    
    func checkAnswer(_ selectedAnswer: String) {
        guard !questionAnswered else { return }
        
        print("Checking answer: \(selectedAnswer)") // Log the answer being checked
        
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
}
