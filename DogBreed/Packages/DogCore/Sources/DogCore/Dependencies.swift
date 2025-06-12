//
//  File.swift
//  DogCore
//
//  Created by Matej on 12. 6. 25.
//

import CoreData
import Foundation

public struct Dependencies {
    
    public let dataManager: DataManager
    
    public init(dataManager: DataManager) {
        self.dataManager = dataManager
    }
}
