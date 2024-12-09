//
//  UserModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

struct UserModel: Codable {
    let email: String
    let name: String
    let address: Address?
    
    enum CodingKeys: CodingKey {
        case email
        case name
        case address
    }
    
    init(userEntity: UserEntity) {
        name = userEntity.name ?? ""
        email = userEntity.email
        address = Address(city: userEntity.city ?? "", street: userEntity.street ?? "")
    }
    
    init(email: String, name: String, address: Address?) {
        self.email = email
        self.name = name
        self.address = address
    }
}
