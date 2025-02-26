//
//  UserRepositoryImplementation.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 26/11/2024.
//

import CoreData
import RxSwift

protocol UserRepository {
    var errorPublisher: Observable<AppError> { get }
    
    func fetchUsers() -> [User]
    func update(with users: [User])
    func addLocalUser(_ user: User)
    func deleteUser(_ user: User)
    func isValidEmail(_ email: String) -> Bool
}

final class UserRepositoryImplementation: UserRepository {
    private let context: NSManagedObjectContext
    private let emailValidationService: ValidationService
    private let errorSubject = PublishSubject<AppError>()
    private let disposeBag = DisposeBag()

    var errorPublisher: Observable<AppError> {
        errorSubject.asObservable()
    }
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared,
         emailValidationService: ValidationService = EmailValidationService()) {
        self.context = coreDataStack.context
        self.emailValidationService = emailValidationService
        
        coreDataStack.errorPublisher
            .subscribe { [weak self] appError in
                self?.errorSubject.onNext(appError)
            }
            .disposed(by: disposeBag)
    }
    
    func fetchUsers() -> [User] {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try context.fetch(fetchRequest)
            return users.map { User(userEntity: $0) }
        } catch {
            errorSubject.onNext(AppError(message: "Failed to fetch users: \(error.localizedDescription)"))
            return []
        }
    }
    
    func update(with users: [User]) {
        let localUsers = fetchUsers()
        let localUserEmails = Set(localUsers.map { $0.email })
        let validUsers = users.filter { isValidEmail($0.email) }
        let newUsers = validUsers.filter { !localUserEmails.contains($0.email.lowercased()) }
        newUsers.forEach { addUserFromNetwork($0) }
        
        saveContext(errorText: "Failed to update users")
    }
    
    func addLocalUser(_ user: User) {
        guard isValidEmail(user.email) else {
            errorSubject.onNext(AppError(message: "Invalid email format: \(user.email)"))
            return
        }
        
        createUserEntity(user, isLocal: true)
        saveContext(errorText: "Failed to save user")
    }
    
    func deleteUser(_ user: User) {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email ==[c] %@", user.email)
        
        do {
            let fetchedUsers = try context.fetch(fetchRequest)
            if let userEntity = fetchedUsers.first {
                context.delete(userEntity)
                saveContext(errorText: "Failed to delete user")
            } else {
                errorSubject.onNext(AppError(message: "User not found"))
            }
        } catch {
            errorSubject.onNext(AppError(message: "Failed to delete user: \(error.localizedDescription)"))
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        emailValidationService.isValid(email)
    }
}

private extension UserRepositoryImplementation {
    func addUserFromNetwork(_ user: User) {
        createUserEntity(user, isLocal: false)
    }
    
    func createUserEntity(_ user: User, isLocal: Bool) {
        let newUser = UserEntity(context: context)
        newUser.name = user.name
        newUser.email = user.email.lowercased()
        newUser.city = user.address?.city
        newUser.street = user.address?.street
        newUser.isLocal = isLocal
    }
    
    func saveContext(errorText: String) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let appError = AppError(message: "\(errorText) - \(error.localizedDescription)")
            errorSubject.onNext(appError)
        }
    }
}
