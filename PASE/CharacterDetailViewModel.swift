//
//  CharacterDetailViewModel.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: RMCharacter
    @Published var episodes: [RMEpisode] = []
    @Published var isFavorite: Bool = false

    private let network: NetworkServiceType
    private let favorites = FavoritesStore.shared

    init(character: RMCharacter, network: NetworkServiceType = NetworkService()) {
        self.character = character
        self.network = network
        self.isFavorite = favorites.isFavorite(id: character.id)
    }

    func loadEpisodes() async {
        let urls = character.episode.compactMap { URL(string: $0) }
        var loaded: [RMEpisode] = []
        for url in urls {
            do {
                let ep = try await network.fetchEpisode(url: url)
                loaded.append(ep)
            } catch {
                // skip failed
            }
        }
        // sort by episode code
        self.episodes = loaded.sorted { $0.id < $1.id }
    }

    func toggleFavorite() {
        isFavorite.toggle()
        if isFavorite {
            favorites.add(id: character.id)
        } else {
            favorites.remove(id: character.id)
        }
    }
}
