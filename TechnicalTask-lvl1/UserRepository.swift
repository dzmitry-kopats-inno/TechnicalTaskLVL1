//
//  UserRepository.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 26/11/2024.
//

import CoreData
import RxSwift

protocol UserRepositoryProtocol {
    func fetchUsers() -> [UserModel]
    func update(with users: [UserModel])
    func addLocalUser(_ user: UserModel)
    func deleteUser(_ user: UserModel) -> Completable
}

final class UserRepository: UserRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = CoreDataStack.shared.context) {
        self.context = context
    }
    
    func fetchUsers() -> [UserModel] {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try context.fetch(fetchRequest)
            return users.map { UserModel(userEntity: $0) }
        } catch {
            debugPrint("Failed to fetch local users with \(error)")
            return []
        }
    }
    
    func update(with users: [UserModel]) {
        let localUsers = fetchUsers()
        let localUserIds = Set(localUsers.map { $0.id })
        let newUsers = users.filter { !localUserIds.contains($0.id) }
        newUsers.forEach { addUserFromNetwork($0) }
        saveContext()
    }
    
    func addLocalUser(_ user: UserModel) {
        createUserEntity(user, isLocal: true)
        saveContext()
    }
    
    func deleteUser(_ user: UserModel) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(NSError(domain: "Repository deallocated", code: -1, userInfo: nil)))
                return Disposables.create()
            }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", user.id)
            
            do {
                let fetchedUsers = try self.context.fetch(fetchRequest)
                
                if let userEntity = fetchedUsers.first {
                    self.context.delete(userEntity)
                    self.saveContext()
                    completable(.completed)
                } else {
                    completable(.error(NSError(domain: "User not found", code: 404, userInfo: nil)))
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
}

// MARK: - Private Methods
private extension UserRepository {
    func addUserFromNetwork(_ user: UserModel) {
        createUserEntity(user, isLocal: false)
    }
    
    func createUserEntity(_ user: UserModel, isLocal: Bool){
        let newUser = UserEntity(context: context)
        newUser.id = Int32(user.id)
        newUser.name = user.name
        newUser.email = user.email
        newUser.city = user.address?.city
        newUser.street = user.address?.street
        newUser.isLocal = isLocal
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            debugPrint("Failed to save Core Data context with \(error)")
        }
    }
}
