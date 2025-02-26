//
//  Endpoint.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/02/2025.
//

import Foundation

enum Endpoint {
    case users
    
    var url: URL {
        switch self {
        case .users:
            URL(string: "https://jsonplaceholder.typicode.com/users")!
        }
    }
    
    var method: String {
        switch self {
        case .users:
            "GET"
        }
    }
}
