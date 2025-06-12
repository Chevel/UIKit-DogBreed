//
//  FavouritePicturesViewModel.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogCore
import Foundation

final class FavouritePicturesViewModel {
    
    // MARK: - Interface properties
    
    var activeFilter = Filter.none {
        didSet {
            switch activeFilter {
            case .none: displayedData = allFavourites.sorted(by: { $0.breed < $1.breed })
            case .breed(let value): displayedData = filterData(by: value)
            }
        }
    }

    // MARK: - Data

    @Published private(set) var displayedData: [URL] = []
    private(set) var breeds: [String] = []
    private var allFavourites: [URL] = []

    // MARK: - Init
    
    init() {
        allFavourites = (FavouritesManager.allFavourites() ?? []).sorted(by: { $0.breed < $1.breed })
        breeds = Array(Set(allFavourites.compactMap({ $0.breed }).sorted(by: <)))
        displayedData = allFavourites
    }
    
    // MARK: - Helper

    private func filterData(by breed: String) -> [URL] {
        return allFavourites.filter({ $0.absoluteString.contains(breed) }).sorted { $0.absoluteString < $1.absoluteString }
    }

}

// MARK: - Filter

extension FavouritePicturesViewModel {
    
    enum Filter {
        case breed(value: String)
        case none
        
        var isActive: Bool {
            switch self {
            case .breed: return true
            case .none: return false
            }
        }
        
        var filterBreed: String? {
            switch self {
            case .breed(let value): return value
            case .none: return nil
            }
        }
    }

}
