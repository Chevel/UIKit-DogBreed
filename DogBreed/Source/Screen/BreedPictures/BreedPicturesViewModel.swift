//
//  BreedPicturesViewModel.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit
import Combine
import DogCore
import DogData
import DogNetwork

@MainActor final class BreedPicturesViewModel: ObservableObject {
    
    // MARK: - Init
    
    @Published private(set) var imagesUrls: [URL] = []

    // MARK: - Init
    
    init(breed: Breed, dogService: DogService) {
        Task(priority: .background, operation: {
            do {
                imagesUrls = try await dogService.imageUrls(for: breed)
            } catch {
                CustomLogger.log(type: .network, message: "Failed loading dog images in \(#function) at \(#file)", error: error)
            }
        })
    }
    
    func breedName(for indexPath: IndexPath) -> String? {
        imagesUrls[safe: indexPath.row]?.breed
    }

    // MARK: - Interface

    func markAsFavourite(imageURL: URL) {
        var isFavourite = FavouritesManager.isFavourite(imageUrl: imageURL)
        isFavourite.toggle()
        FavouritesManager.markAsFavourite(isFavourite: isFavourite, imageURL: imageURL)
    }
}
