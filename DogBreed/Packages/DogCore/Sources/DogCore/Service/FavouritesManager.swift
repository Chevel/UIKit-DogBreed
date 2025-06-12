//
//  FavouritesManager.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

public final actor FavouritesManager {
        
    // MARK: - Init

    private init() {}

    // MARK: - Interface

    public static func isFavourite(imageUrl: URL) -> Bool {
        guard
            let favouritesData = UserDefaults.standard.object(forKey: UserDefaults.Keys.favouritePictures.rawValue) as? [String: Bool]
        else {
            return false
        }
        return favouritesData[imageUrl.absoluteString] ?? false
    }

    public static func markAsFavourite(isFavourite: Bool, imageURL: URL) {
        guard
            var favouritesData = UserDefaults.standard.object(forKey: UserDefaults.Keys.favouritePictures.rawValue) as? [String: Bool]
        else {
            UserDefaults.standard.set([imageURL.absoluteString: isFavourite], forKey: UserDefaults.Keys.favouritePictures.rawValue)
            UserDefaults.standard.synchronize()
            return
        }
        favouritesData[imageURL.absoluteString] = isFavourite
        
        UserDefaults.standard.set(favouritesData, forKey: UserDefaults.Keys.favouritePictures.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    public static func allFavourites() -> [URL]? {
        guard
            let favouritesData = UserDefaults.standard.object(forKey: UserDefaults.Keys.favouritePictures.rawValue) as? [String: Bool]
        else {
            return nil
        }
        return favouritesData.filter { $0.value }.keys.compactMap({ URL(string: $0) })
    }
}
