//
//  ImageCache.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

final actor ImageCache {
    
    private typealias ImageDownloadTask = Task<UIImage, Error>
    
    // MARK: - Init

    static let shared = ImageCache()
    
    private init() {}

    // MARK: - Properties

    private let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 80
        return cache
    }()

    private let picturesDirURL: URL? = FileManager.default
        .urls(for: .cachesDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("DogPictures")
    
    // MARK: - Images

    func image(at url: URL) async -> UIImage? {
        if let cachedImage = imageCache.object(forKey: url.imageIdentifier as NSString) {
            return cachedImage
        } else if let storedImage = loadImage(forKey: url.imageIdentifier) {
            return storedImage
        } else {
            return await downloadImage(at: url)
        }
    }
}

private extension URL {
    
    var imageIdentifier: String {
        lastPathComponent
    }
}

// MARK: - Network

private extension ImageCache {

    func downloadImage(at imageURL: URL) async -> UIImage? {
        let image = try? await ImageDownloadTask {
            try await withCheckedThrowingContinuation { continuation in
                URLSession.shared.dataTask(with: imageURL as URL, completionHandler: { (data, response, error) in
                    if let error = error {
                        continuation.resume(throwing: error)
                        
                    } else if let data = data, let image = UIImage(data: data) {
                        continuation.resume(returning: image)

                    } else {
                        continuation.resume(throwing: ParseError(domain: imageURL.absoluteString))
                    }
                }).resume()
            }
        }.value
        
        if let image {
            store(image: image, forKey: imageURL.imageIdentifier)
            imageCache.setObject(image, forKey: imageURL.imageIdentifier as NSString)
        } else {
            print("")
        }

        return image
    }
}

// MARK: - Disk

private extension ImageCache {

    func loadImage(forKey key: String) -> UIImage? {
        guard
            let filePath = picturesDirURL?.appendingPathComponent(key),
            let fileData = FileManager.default.contents(atPath: filePath.path)
        else {
            return nil
        }
        guard let image = UIImage(data: fileData) else {
            CustomLogger.log(type: .imageCache, message: "Failed to unwrap image data in \(#file) at \(#line)", error: ParseError())
            return nil
        }

        return image
    }

    func store(image: UIImage, forKey key: String) {
        guard
            let pngRepresentation = image.pngData(), let filePath = picturesDirURL?.appendingPathComponent(key),
            let picturesDir = picturesDirURL
        else {
            CustomLogger.log(type: .imageCache, message: "Failed to unwrap image data in \(#file) at \(#line)", error: ParseError())
            return
        }
        
        do {
            if !FileManager.default.fileExists(atPath: picturesDir.absoluteString) {
                try? FileManager.default.createDirectory(at: picturesDir, withIntermediateDirectories: false, attributes: nil)
            }
            try pngRepresentation.write(to: filePath, options: .completeFileProtection)
        } catch {
            CustomLogger.log(type: .imageCache, message: "Failed to save image at \(filePath).", error: error)
        }
    }
}
