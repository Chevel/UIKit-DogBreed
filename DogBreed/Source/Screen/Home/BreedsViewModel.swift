//
//  BreedsViewModel.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import DogCore
import DogData
import Foundation

@MainActor final class BreedsViewModel: ObservableObject {
    
    @Published private(set) var breeds: [Breed]? = nil
    
    init(dataManager: DataManager) {
        Task(priority: .background, operation: {
            do {
                // Load from DB
                self.breeds = try await dataManager.loadBreeds()

                // Load from BE
                let newBreeds = try await DogService(session: URLSession.shared).breeds().breeds
                try await dataManager.update(breeds: newBreeds)
                self.breeds = newBreeds
            } catch {
                CustomLogger.log(type: .network, message: "Failed loading breeds in \(#function) at \(#file)", error: error)
            }
        })
    }
}
