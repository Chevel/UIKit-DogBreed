//
//  DataManager.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

protocol DoggyDatabase: AnyObject {
    
    func create(breeds: [String]) async throws
    func loadBreeds() async throws -> [BreedsDBModel]

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

    func update(breeds: [String]) async throws {
        try await databaseManager.create(breeds: breeds)
    }
    
    // MARK: - Load
    
    func loadBreeds() async throws -> [String] {
        let breedDbModels = try await databaseManager.loadBreeds()
        return breedDbModels.compactMap { $0.name }.sorted(by: <)
    }
    
}

