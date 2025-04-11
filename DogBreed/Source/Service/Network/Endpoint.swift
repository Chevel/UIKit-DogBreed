//
//  Endpoint.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

enum Endpoint {

    case breeds
    case breedImages(breed: String)

    var path: String {
        switch self {
        case .breeds: return "/api/breeds/list/all"
        case .breedImages(let breed): return "/api/breed/\(breed)/images"
        }
    }

    var method: String {
        switch self {
        case .breeds, .breedImages: return "GET"
        }
    }

}
