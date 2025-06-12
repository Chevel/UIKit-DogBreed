//
//  UICollectionView+CellFactory.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

public protocol BreedPictureCellDisplayable: UIViewController {}

public extension BreedPictureCellDisplayable {
    
    func dequeueBreedPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> DogUI.BreedPictures.CollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DogUI.BreedPictures.CollectionViewCell.identifier,
            for: indexPath
        ) as? DogUI.BreedPictures.CollectionViewCell else {
            fatalError("⛔️ Error in \(#file) at \(#line) - \(DogUI.BreedPictures.CollectionViewCell.self) is not registered on \(self).")
        }
        return cell
    }
}
