//
//  Logger.swift
//  DogBreed
//
//  Created by Matej on 30/08/2022.
//  Copyright © 2022 Matej Kokosinek. All rights reserved.
//

import Foundation
import OSLog

public final class CustomLogger {

    // MARK: - Event

    public enum Event {
        case imageCache
        case network
        case dataBase

        public var symbol: String {
            switch self {
            case .imageCache: return "🖼"
            case .network: return "📡"
            case .dataBase: return "💾"
            }
        }
    }
 
    // MARK: - Init

    private init() {}
    
    // MARK: - Interface

    public static func log(type: Event, message: String, error: Error? = nil) {
        if let error = error {
            Logger().log(level: .error, "\(type.symbol) - \(message) with error: \(error.localizedDescription)")
        } else {
            Logger().log(level: .info, "\(type.symbol) - SUCCESS - \(message)")
        }
    }
}
