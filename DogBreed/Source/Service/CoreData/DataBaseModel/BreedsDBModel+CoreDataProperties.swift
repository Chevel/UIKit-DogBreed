//
//  BreedsDBModel+CoreDataProperties.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//
//

import Foundation
import CoreData


extension BreedsDBModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BreedsDBModel> {
        return NSFetchRequest<BreedsDBModel>(entityName: "BreedsDBModel")
    }

    @NSManaged public var name: String?

}

extension BreedsDBModel : Identifiable {

}
