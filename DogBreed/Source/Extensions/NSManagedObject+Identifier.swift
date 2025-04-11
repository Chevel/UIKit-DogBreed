//
//  NSManagedObject+Identifier.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {

    static var entityName: String {
        return String(describing: self)
    }

}
