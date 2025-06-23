//
//  Dependencies.swift
//  DogBreedContainer
//
//  Created by Matej on 12. 6. 25.
//

import DogCore
import DogNetwork
import Foundation

public struct Dependencies {
    
    public let dataManager: DataManager
    public let networkService: DogService
    
    public init(dataManager: DataManager, networkService: DogService) {
        self.dataManager = dataManager
        self.networkService = networkService
    }
}
