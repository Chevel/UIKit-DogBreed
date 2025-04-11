//
//  ErrorDomain.swift
//  DogBreed
//
//  Created by Matej on 27/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation

struct ParseError: Error {
    let domain: String?
    
    init(domain: String? = nil) {
        self.domain = domain
    }
}

enum ServiceError: Error {
    case noData
    case parsing
}

enum DataBaseError: Error {

    case save(object: Any)
    case fetch
    case delete

    var description: String {
        switch self {
        case .save(let object): return "Failed to Save \(object)"
        case .fetch: return "Failed to Fetch"
        case .delete: return "Failed to Delete"
        }
    }

}
