//
//  FavoritesStore.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation

final class FavoritesStore {
    static let shared = FavoritesStore()
    private let key = "RMFavorites"
    private var set: Set<Int>

    private init() {
        if let arr = UserDefaults.standard.array(forKey: key) as? [Int] {
            set = Set(arr)
        } else {
            set = []
        }
    }

    func isFavorite(id: Int) -> Bool {
        set.contains(id)
    }

    func add(id: Int) {
        set.insert(id)
        persist()
    }

    func remove(id: Int) {
        set.remove(id)
        persist()
    }

    private func persist() {
        UserDefaults.standard.set(Array(set), forKey: key)
    }
}
