//
//  ImageLoader.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
final class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    private let url: URL?
    private let network: NetworkServiceType
    private var task: Task<Void, Never>?
    private let cache: ImageCacheType

    init(urlString: String?, network: NetworkServiceType = NetworkService(), cache: ImageCacheType = ImageCache.shared) {
        if let s = urlString { self.url = URL(string: s) } else { self.url = nil }
        self.network = network
        self.cache = cache
    }

    func load() {
        guard let url = url else { return }
        if let cached = cache.image(forKey: url) {
            self.image = cached
            return
        }
        task = Task {
            do {
                let data = try await network.fetchData(url: url)
                if let uiImage = UIImage(data: data) {
                    cache.insertImage(uiImage, forKey: url)
                    self.image = uiImage
                }
            } catch {
                // ignore or set placeholder
            }
        }
    }

    func cancel() {
        task?.cancel()
        task = nil
    }
}
