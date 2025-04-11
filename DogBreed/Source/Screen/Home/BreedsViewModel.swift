//
//  BreedsViewModel.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

@MainActor final class BreedsViewModel: ObservableObject {
    
    @Published private(set) var breeds: [String]? = nil
    
    init() {
        Task(priority: .background, operation: {
            do {
                // Load from DB
                self.breeds = try await DataManager.shared.loadBreeds()

                // Load from BE
                let newBreeds = try await DogService(session: URLSession.shared).breeds().breeds
                try await DataManager.shared.update(breeds: newBreeds)
                self.breeds = newBreeds
            } catch {
                CustomLogger.log(type: .network, message: "Failed loading breeds in \(#function) at \(#file)", error: error)
            }
        })
    }
    
}
