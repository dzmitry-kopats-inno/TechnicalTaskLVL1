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
    
    init(userEntity: UserEntity) {
        id = Int(userEntity.id)
        name = userEntity.name ?? ""
        email = userEntity.email
        address = Address(city: userEntity.city ?? "", street: userEntity.street ?? "")
    }
    
    init(id: Int, email: String, name: String, address: Address?) {
        self.id = id
        self.email = email
        self.name = name
        self.address = address
    }
}
