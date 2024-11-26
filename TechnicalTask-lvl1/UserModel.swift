//
//  UserModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation

struct UserModel: Codable {
    let id: Int
    let email: String
    let name: String
    let address: Address?
    
    enum CodingKeys: CodingKey {
        case id
        case email
        case name
        case address
    }
}
