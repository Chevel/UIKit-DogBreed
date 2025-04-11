//
//  DogBreedResponse.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

struct DogBreedResponse: Decodable {
    
    let message: [String: [String]]
    
    var breeds: [String] {
        return Array(message.keys).sorted(by: <)
    }

}
