//
//  DogServiceTests.swift
//  DogServiceTests
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import XCTest
@testable import DogBreed

class DogServiceTests: XCTestCase {
    
    // MARK: - Properties
    
    private var session: URLSession!

    // MARK: - Setup
    
    override func setUp() {
        super.setUp()

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [DogBreedMockUrlProtocol.self]
        session = URLSession(configuration: config)
    }

    // MARK: - Tests

    func testBreeds() async throws {
        let url = DogService.buildRequest(for: .breeds)?.url
        XCTAssertNotNil(url)

        let breeds = try await DogService(session: session).breeds()
        XCTAssertEqual(breeds.breeds.count, 96)
        XCTAssertEqual(breeds.breeds[0], "affenpinscher")
        XCTAssertEqual(breeds.breeds[5], "australian")
        if let breedCount = breeds.message["australian"]?.count {
            XCTAssertEqual(breedCount, 1)
        } else {
            XCTAssertTrue(false)
        }
        
        if let breed = breeds.message["australian"]?.first {
            XCTAssertEqual(breed, "shepherd")
        } else {
            XCTAssertTrue(false)
        }
        
        XCTAssertNil(breeds.message["basenji"]?.first)
        XCTAssertNil(breeds.message["bagel"])
        XCTAssertNotNil(breeds.message["beagle"])
        
        guard let url = url else {
            XCTAssertTrue(false)
            return
        }
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "dog.ceo")
        XCTAssertEqual(url.path, Endpoint.breeds.path)
    }
    
    func testBreedImages() async throws {
        let breed = "hound-ibizan"

        XCTAssertNotNil(DogService.buildRequest(for: .breedImages(breed: breed))?.url)
        let imagesResponse = try await DogService(session: session).images(for: breed)
        XCTAssertTrue(imagesResponse.isResponseValid)

        guard let imageUrlString = imagesResponse.message.first else {
            XCTAssertTrue(false)
            return
        }

        guard let url = URL(string: imageUrlString) else {
            XCTAssertTrue(false)
            return
        }
        
        XCTAssertEqual(url.scheme, "https")
        XCTAssertEqual(url.host, "images.dog.ceo")
        XCTAssertEqual(url.lastPathComponent, "n02091244_100.jpg")
    }

}
