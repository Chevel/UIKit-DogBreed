//
//  Breed.swift
//  DogBreed
//
//  Created by Matej on 12. 6. 25.
//  Copyright © 2025 Matej Kokosinek. All rights reserved.
//

public struct Breed: Sendable, Hashable {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
