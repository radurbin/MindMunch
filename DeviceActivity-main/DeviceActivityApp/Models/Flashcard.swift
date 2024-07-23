//
//  Flashcard.swift
//  DeviceActivityApp
//
//  Created by Riley Durbin on 7/23/24.
//

import Foundation

struct Flashcard: Identifiable {
    let id: Int
    let term: String
    let definition: String
}

struct APIResponse: Codable {
    let responses: [Response]
}

struct Response: Codable {
    let models: Models
    let paging: Paging?
}

struct Models: Codable {
    let studiableItem: [StudiableItem]
}

struct StudiableItem: Codable {
    let id: Int
    let cardSides: [CardSide]
}

struct CardSide: Codable {
    let sideId: Int
    let label: String
    let media: [Media]
}

struct Media: Codable {
    let type: Int
    let plainText: String?
}

struct Paging: Codable {
    let total: Int
    let page: Int
    let perPage: Int
    let token: String?
}
