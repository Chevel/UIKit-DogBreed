//
//  ErrorDomain.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

public struct ParseError: Error {
    let domain: String?
    
    public init(domain: String? = nil) {
        self.domain = domain
    }
}

public enum ServiceError: Error {
    case noData
    case parsing
}

public enum DataBaseError: Error {

    case save(object: Sendable)
    case fetch
    case delete

    public var description: String {
        switch self {
        case .save(let object): return "Failed to Save \(object)"
        case .fetch: return "Failed to Fetch"
        case .delete: return "Failed to Delete"
        }
    }
}
