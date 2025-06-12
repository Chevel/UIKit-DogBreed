//
//  CoreDataManager.swift
//  DogBreed
//
//  Created by Matej on 04/09/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogData
import DogCore
import Foundation
import UIKit.UIApplication
@preconcurrency import CoreData

final actor CoreDataManager: DoggyDatabase {

    // MARK: - Properties

    private let persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: Bundle.Configuration.CoreData.persistenceContainerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                let message = error.userInfo.map { "\($0.key):\($0.value)" }.joined(separator: "\n")
                CustomLogger.log(type: .dataBase, message: message, error: error)
            }
        })
        return container
    }()

    private var managedContext: NSManagedObjectContext? {
        persistentContainer.viewContext
    }

    // MARK: - Create

    func create(breeds: [Breed]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            Task(priority: .background, operation: {
                guard let context = self.managedContext else {
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
                guard let context = self.managedContext else {
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
    
    // MARK: - Save
    
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let message = (error as NSError).userInfo.map { "\($0.key):\($0.value)" }.joined(separator: "\n")
                CustomLogger.log(type: .dataBase, message: message, error: error)
            }
        }
    }
}
