//
//  ImageCache.swift
//  PASE
//
//  Created by Maul Camlopz on 27/08/25.
//

import Foundation
import UIKit

protocol ImageCacheType {
    func image(forKey: URL) -> UIImage?
    func insertImage(_ image: UIImage?, forKey: URL)
}

final class ImageCache: ImageCacheType {
    static let shared = ImageCache()
    private let cache = NSCache<NSURL, UIImage>()

    private init() {}

    func image(forKey: URL) -> UIImage? {
        cache.object(forKey: urlKey(for: forKey))
    }

    func insertImage(_ image: UIImage?, forKey: URL) {
        guard let image = image else {
            cache.removeObject(forKey: urlKey(for: forKey))
            return
        }
        cache.setObject(image, forKey: urlKey(for: forKey))
    }

    private func urlKey(for url: URL) -> NSURL {
        return url as NSURL
    }
}

