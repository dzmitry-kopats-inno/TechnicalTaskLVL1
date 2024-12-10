//
//  UserRepositoryImplementation.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 26/11/2024.
//

import CoreData
import RxSwift

protocol UserRepository {
    func fetchUsers() -> [UserModel]
    func update(with users: [UserModel])
    func addLocalUser(_ user: UserModel)
    func deleteUser(_ user: UserModel) -> Completable
    func isValidEmail(_ email: String) -> Bool
}

final class UserRepositoryImplementation: UserRepository {
    private let context: NSManagedObjectContext
    private let emailValidationService: ValidationService
    
    init(context: NSManagedObjectContext = CoreDataStack.shared.context,
         emailValidationService: ValidationService = EmailValidationService()) {
        self.context = context
        self.emailValidationService = emailValidationService
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
        let localUserEmails = Set(localUsers.map { $0.email })
        let validUsers = users.filter { isValidEmail($0.email) }
        let newUsers = validUsers.filter { !localUserEmails.contains($0.email) }
        newUsers.forEach { addUserFromNetwork($0) }
        saveContext()
    }
    
    func addLocalUser(_ user: UserModel) {
        guard isValidEmail(user.email) else {
            // TODO: - Add error here
            debugPrint("Invalid email format: \(user.email)")
            return
        }
        
        createUserEntity(user, isLocal: true)
        saveContext()
    }
    
    func deleteUser(_ user: UserModel) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(AppError(message: "Repository deallocated")))
                return Disposables.create()
            }
            
            let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "email ==[c] %@", user.email)
            
            do {
                let fetchedUsers = try self.context.fetch(fetchRequest)
                
                if let userEntity = fetchedUsers.first {
                    self.context.delete(userEntity)
                    self.saveContext()
                    completable(.completed)
                } else {
                    completable(.error(AppError(message: "User not found")))
                }
            } catch {
                completable(.error(error))
            }
            
            return Disposables.create()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        emailValidationService.isValid(email)
    }
}

// MARK: - Private Methods
private extension UserRepositoryImplementation {
    func addUserFromNetwork(_ user: UserModel) {
        createUserEntity(user, isLocal: false)
    }
    
    func createUserEntity(_ user: UserModel, isLocal: Bool){
        let newUser = UserEntity(context: context)
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
