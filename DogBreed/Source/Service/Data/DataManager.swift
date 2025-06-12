//
//  DataManager.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

protocol DoggyDatabase: Actor {
    
    func create(breeds: [Breed]) async throws
    func loadBreeds() async throws -> [Breed]
}

final actor DataManager {

    fileprivate(set) static var shared: DataManager!

    // MARK: - Properties
    
    private let databaseManager: DoggyDatabase

    // MARK: - Init

    private init(databaseManager: DoggyDatabase) {
        self.databaseManager = databaseManager
    }
    
    static func setup(with databaseManager: DoggyDatabase) {
        Self.shared = DataManager(databaseManager: databaseManager)
    }
    
    // MARK: - Update

    func update(breeds: [Breed]) async throws {
        try await databaseManager.create(breeds: breeds)
    }
    
    // MARK: - Load
    
    func loadBreeds() async throws -> [Breed] {
        try await databaseManager
            .loadBreeds()
            .sorted { $0.name < $1.name }
    }
}
