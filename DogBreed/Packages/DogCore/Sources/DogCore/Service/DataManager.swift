//
//  DataManager.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogData
import Foundation

public final actor DataManager {

    // MARK: - Properties
    
    private let databaseManager: DoggyDatabase

    // MARK: - Init

    public init(databaseManager: DoggyDatabase) {
        self.databaseManager = databaseManager
    }

    // MARK: - Update

    public func update(breeds: [Breed]) async throws {
        try await databaseManager.create(breeds: breeds)
    }
    
    // MARK: - Load
    
    public func loadBreeds() async throws -> [Breed] {
        try await databaseManager
            .loadBreeds()
            .sorted { $0.name < $1.name }
    }
    
    // MARK: - Save/Persist
    
    public func savePendingChanges() async {
        await databaseManager.save()
    }
}
