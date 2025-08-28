//
//  NetworkService.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation

protocol NetworkServiceType {
    func fetchCharacters(page: Int) async throws -> CharactersResponse
    func fetchEpisode(url: URL) async throws -> RMEpisode
    func fetchData(url: URL) async throws -> Data
}

final class NetworkService: NetworkServiceType {
    private let base = "https://rickandmortyapi.com/api"
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCharacters(page: Int = 1) async throws -> CharactersResponse {
        guard let url = URL(string: "\(base)/character?page=\(page)") else {
            throw URLError(.badURL)
        }
        let (data, resp) = try await session.data(from: url)
        try validateResponse(resp)
        let decoder = JSONDecoder()
        return try decoder.decode(CharactersResponse.self, from: data)
    }

    func fetchEpisode(url: URL) async throws -> RMEpisode {
        let (data, resp) = try await session.data(from: url)
        try validateResponse(resp)
        let decoder = JSONDecoder()
        return try decoder.decode(RMEpisode.self, from: data)
    }

    func fetchData(url: URL) async throws -> Data {
        let (data, resp) = try await session.data(from: url)
        try validateResponse(resp)
        return data
    }

    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
    }
}
