//
//  CharacterListViewModel.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation
import SwiftUI

@MainActor
final class CharacterListViewModel: ObservableObject {
    @Published private(set) var characters: [RMCharacter] = []
    @Published var isLoading: Bool = false
    @Published var page: Int = 1
    @Published var errorMessage: String?

    private let network: NetworkServiceType

    init(network: NetworkServiceType = NetworkService()) {
        self.network = network
    }

    func load(page: Int = 1) async {
        isLoading = true
        errorMessage = nil
        do {
            let resp = try await network.fetchCharacters(page: page)
            if page == 1 {
                self.characters = resp.results
            } else {
                self.characters.append(contentsOf: resp.results)
            }
            self.page = page
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func refresh() async {
        await load(page: 1)
    }
}
