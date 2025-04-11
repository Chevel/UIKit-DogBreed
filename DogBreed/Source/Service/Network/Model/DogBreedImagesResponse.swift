//
//  DogBreedImagesResponse.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

struct DogBreedImagesResponse: Decodable {

    let message: [String]
    let status: String

    var isResponseValid: Bool { status == "success" }
    var urls: [URL] { message.compactMap { URL(string: $0) }}
    
}
