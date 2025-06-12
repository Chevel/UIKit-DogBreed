//
//  DogBreedResponse.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogData
import Foundation

struct DogBreedResponse: Decodable {
    
    let message: [String: [String]]
    
    var breeds: [Breed] {
        Array(message.keys)
            .sorted(by: <)
            .map({ Breed(name: $0) })
    }
}
