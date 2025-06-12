//
//  CoreDataManager.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation
@preconcurrency import CoreData
import UIKit.UIApplication

final actor CoreDataManager: DoggyDatabase {

    // MARK: - Properties
    
    @MainActor
    private var managedContext: NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - Create

    func create(breeds: [Breed]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task(priority: .background, operation: {
                guard let context = await self.managedContext else {
                    continuation.resume(throwing: ParseError())
                    return
                }

                let storedBreeds = try await loadBreeds()

                // Create new entries that are not stored
                for breed in breeds where !storedBreeds.contains(where: { $0.name == breed.name }) {
                    let newBreedsDbModel = BreedsDBModel(context: context)
                    newBreedsDbModel.name = breed.name
                }

                // Save
                do {
                    guard context.hasChanges else {
                        continuation.resume()
                        return
                    }
                    try context.save()
                    continuation.resume()
                } catch let error as NSError {
                    CustomLogger.log(type: .dataBase, message: "Failed saving Breeds \(breeds)", error: error)
                    continuation.resume(throwing: DataBaseError.save(object: breeds))
                }
            })
        }
    }
    
    // MARK: - Read
    
    func loadBreeds() async throws -> [Breed] {
        return try await withCheckedThrowingContinuation { continuation in
            Task(priority: .background, operation: {
                guard let context = await self.managedContext else {
                    continuation.resume(throwing: ParseError())
                    return
                }
                
                do {
                    let fetchRequest = NSFetchRequest<BreedsDBModel>(entityName: BreedsDBModel.entityName)
                    let breedDbModels = try context.fetch(fetchRequest).compactMap {
                        if let name = $0.name {
                            Breed(name: name)
                        } else {
                            nil
                        }
                    }
                    continuation.resume(returning: breedDbModels)
                } catch let error as NSError {
                    CustomLogger.log(type: .dataBase, message: "Failed fetching Breeds", error: error)
                    continuation.resume(throwing: DataBaseError.fetch)
                }
            })
        }
    }
    
}
