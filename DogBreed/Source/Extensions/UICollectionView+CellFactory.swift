//
//  UICollectionView+CellFactory.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

protocol BreedPictureCellDisplayable: UIViewController {}

extension BreedPictureCellDisplayable {
    
    func dequeueBreedPictureCell(for collectionView: UICollectionView, at indexPath: IndexPath) -> BreedPictureCollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BreedPictureCollectionViewCell.identifier, for: indexPath) as? BreedPictureCollectionViewCell else {
            fatalError("⛔️ Error in \(#file) at \(#line) - \(BreedPictureCollectionViewCell.self) is not registered on \(self).")
        }
        return cell
    }
    
}
