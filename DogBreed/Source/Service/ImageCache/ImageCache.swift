//
//  ImageCache.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

final actor ImageCache {
    
    // MARK: - Init

    static let shared = ImageCache()
    
    private init() {}
    
    // MARK: - Properties
    
    private lazy var imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 80
        return cache
    }()

    private var picturesDirURL: URL? {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("DogPictures")
    }

    // MARK: - Images

    func image(at url: URL) async throws -> UIImage {
        let imageName = url.lastPathComponent
        if let cachedImage = imageCache.object(forKey: imageName as NSString) {
            return cachedImage
        } else if let storedImage = loadImage(forKey: imageName) {
            return storedImage
        } else {
            return try await downloadImage(at: url)
        }
    }

}

// MARK: - Network

private extension ImageCache {
    
    func downloadImage(at imageURL: URL) async throws -> UIImage {
        let imageName = imageURL.lastPathComponent
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: imageURL as URL, completionHandler: { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let image = UIImage(data: data) {
                    self.imageCache.setObject(image, forKey: imageName as NSString)
                    self.store(image: image, forKey: imageName)

                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: ParseError(domain: imageURL.absoluteString))
                }
            }).resume()
        }
    }
    
}

// MARK: - Disk

private extension ImageCache {
    
    func loadImage(forKey key: String) -> UIImage? {
        guard
            let filePath = self.filePath(forKey: key),
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
            let pngRepresentation = image.pngData(), let filePath = filePath(forKey: key),
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
    
    func filePath(forKey key: String) -> URL? {
        return picturesDirURL?.appendingPathComponent(key)
    }
    
}
