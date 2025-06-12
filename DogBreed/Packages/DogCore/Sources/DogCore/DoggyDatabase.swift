//
//  DoggyDatabase.swift
//  DogCore
//
//  Created by Matej on 12. 6. 25.
//

import DogData

public protocol DoggyDatabase: Actor {
    
    func create(breeds: [Breed]) async throws
    func loadBreeds() async throws -> [Breed]
    func save()
}
