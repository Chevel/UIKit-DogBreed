//
//  UIImage+SFSymbols.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import UIKit

public extension UIImage {

    static var warning: UIImage {
        return UIImage(systemName: "exclamationmark.triangle.fill")!.withTintColor(.gray)
    }

    static var placeholder: UIImage {
        return UIImage(systemName: "photo")!.withTintColor(.gray)
    }
    
    static var favouriteEmpty: UIImage {
        return UIImage(systemName: "heart")!
            .withTintColor(.red)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
    }
    
    static var favouriteFull: UIImage {
        return UIImage(systemName: "heart.fill")!
            .withTintColor(.red)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 30))
    }
    
    static var filterInactiveIcon: UIImage {
        return UIImage(systemName: "line.3.horizontal.decrease.circle")!
    }
    
    static var filterActiveIcon: UIImage {
        return UIImage(systemName: "line.3.horizontal.decrease.circle.fill")!
    }
    
    static var checkmarkIcon: UIImage {
        return UIImage(systemName: "checkmark")!
    }
}
