//
//  NSLocalizedString+Extension.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

extension String {

    func translated() -> String {
        return NSLocalizedString(self, comment: "")
    }

}
