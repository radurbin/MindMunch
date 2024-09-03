//
//  Flashcard.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import Foundation

// The Flashcard struct represents a single flashcard with an identifiable ID, a term, and its corresponding definition.
// It conforms to Identifiable and Codable protocols, enabling easy identification and encoding/decoding to/from JSON.
struct Flashcard: Identifiable, Codable {
    let id: Int         // Unique identifier for each flashcard
    let term: String    // The term or question on the flashcard
    let definition: String // The definition or answer on the flashcard
}

// The APIResponse struct is used to parse the response from the Quizlet API.
// It contains an array of Response objects, which represent the different sets of flashcards.
struct APIResponse: Codable {
    let responses: [Response] // Array of response objects, each representing a set of flashcards
}

// The Response struct represents the individual response returned by the API.
// It contains the models and paging information related to flashcards.
struct Response: Codable {
    let models: Models    // Models object containing the studiable items (flashcards)
    let paging: Paging?   // Optional paging information to handle multiple pages of results
}

// The Models struct contains an array of StudiableItem objects.
// These items represent the flashcards themselves.
struct Models: Codable {
    let studiableItem: [StudiableItem] // Array of studiable items (flashcards)
}

// The StudiableItem struct represents an individual flashcard with its ID and card sides.
// A flashcard typically has two sides: one for the term and one for the definition.
struct StudiableItem: Codable {
    let id: Int            // Unique identifier for the studiable item (flashcard)
    let cardSides: [CardSide] // Array of card sides (usually term and definition)
}

// The CardSide struct represents one side of a flashcard, containing a label and media.
// Media can be either text or other forms of content (like images or audio).
struct CardSide: Codable {
    let sideId: Int       // Unique identifier for the side of the flashcard
    let label: String     // Label describing the side (e.g., "front" or "back")
    let media: [Media]    // Array of media objects, typically containing text or other content
}

// The Media struct represents the content of a flashcard side.
// It contains the type of media (e.g., text, image) and the actual text content, if any.
struct Media: Codable {
    let type: Int          // Type of media (e.g., 1 for text, 2 for image, etc.)
    let plainText: String? // Optional plain text content associated with this media type
}

// The Paging struct provides pagination details for the API response.
// It helps in handling large sets of flashcards by dividing them into pages.
struct Paging: Codable {
    let total: Int         // Total number of items available
    let page: Int          // Current page number
    let perPage: Int       // Number of items per page
    let token: String?     // Optional token for retrieving the next page
}
