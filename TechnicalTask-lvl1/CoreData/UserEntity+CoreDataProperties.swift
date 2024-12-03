//
//  UserEntity+CoreDataProperties.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 26/11/2024.
//
//

import Foundation
import CoreData


extension UserEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
        return NSFetchRequest<UserEntity>(entityName: "UserEntity")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var email: String
    @NSManaged public var city: String?
    @NSManaged public var street: String?
    @NSManaged public var isLocal: Bool

}

extension UserEntity : Identifiable {

}
