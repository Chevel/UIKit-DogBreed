//
//  DogBreedMockUrlProtocol.swift
//  DogBreed
//
//  Created by Matej on 31/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

class DogBreedMockUrlProtocol: URLProtocol {
    
    // MARK: - URLProtocol
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let url = request.url else {
            return
        }
        
        if url.absoluteString == "https://dog.ceo/api/breeds/list/all" {
            if let path = Bundle.main.url(forResource: "breeds", withExtension: "json"),
               let jsonData = try? Data(contentsOf: path, options: .mappedIfSafe) {
                self.client?.urlProtocol(self, didLoad: jsonData)
            }
        } else if url.absoluteString == "https://dog.ceo/api/breed/hound-ibizan/images" {
            if let path = Bundle.main.url(forResource: "breed-images", withExtension: "json"),
               let jsonData = try? Data(contentsOf: path, options: .mappedIfSafe) {
                self.client?.urlProtocol(self, didLoad: jsonData)
            }
        }

        self.client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }

}
