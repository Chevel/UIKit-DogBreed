//
//  DogService.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

final actor DogService {
    
    private let session: URLSession
        
    // MARK: - Init
    
    init(session: URLSession) {
        self.session = session
    }
    
    // MARK: - Breeds
    
    func breeds() async throws -> DogBreedResponse {
        guard let request = Self.buildRequest(for: .breeds) else {
            throw ParseError()
        }
        return try await perform(request: request)
    }
    
    func images(for breed: String) async throws -> DogBreedImagesResponse {
        guard let request = Self.buildRequest(for: .breedImages(breed: breed)) else {
            throw ParseError()
        }
        return try await perform(request: request)
    }
    
    // MARK: - Helper
    
    private func perform<T: Decodable>(request: URLRequest) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.dataTask(with: request) { data, response, error in
                guard let jsonData = data else {
                    continuation.resume(throwing: ServiceError.noData)
                    return
                }
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    do {
                        let response = try JSONDecoder().decode(T.self, from: jsonData)
                        continuation.resume(returning: response)
                    } catch {
                        continuation.resume(throwing: ServiceError.parsing)
                    }
                }
            }.resume()
        }
    }

    static func buildRequest(for endpoint: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "dog.ceo"
        components.path = endpoint.path
        guard let url = components.url else {
            CustomLogger.log(type: .network, message: "Failed to create URL request in \(#file) at \(#line) for \(endpoint)", error: ParseError())
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        return request
    }
    
}
