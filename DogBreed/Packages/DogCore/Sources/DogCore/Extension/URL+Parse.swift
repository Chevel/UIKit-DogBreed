//
//  URL+Parse.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

public extension URL {

    var breed: String {
        String(self.absoluteString
            .dropFirst("https://images.dog.ceo/breeds/".count)
            .split(separator: "/")
            .first ?? "")
    }
}
