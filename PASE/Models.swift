//
//  Models.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation

// MARK: - API response models (decodable)
struct CharactersResponse: Decodable {
    let info: PageInfo
    let results: [RMCharacter]
}

struct PageInfo: Decodable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct RMCharacter: Decodable, Identifiable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: RMOrigin
    let location: RMLocationRef
    let image: String
    let episode: [String] // episode URLs
    let url: String
    let created: String
}

struct RMOrigin: Decodable {
    let name: String
    let url: String
}

struct RMLocationRef: Decodable {
    let name: String
    let url: String
}

// Episode model (we'll fetch by URL)
struct RMEpisode: Decodable, Identifiable {
    let id: Int
    let name: String
    let episode: String
    let air_date: String
    let characters: [String]
    let url: String
    let created: String
}
