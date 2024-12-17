//
//  AddUserViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 27/11/2024.
//

import Foundation
import RxSwift

final class AddUserViewModel {
    private let userRepository: UserRepository
    private let errorSubject = PublishSubject<Error>()
    private let successSubject = PublishSubject<Void>()
    private let disposeBag = DisposeBag()

    var error: Observable<Error> {
        errorSubject.asObservable()
    }

    var success: Observable<Void> {
        successSubject.asObservable()
    }
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        
        userRepository.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self else { return }
                errorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }

    func addUser(name: String?, email: String?, city: String?, street: String?) {
        do {
            guard let name = name, !name.isEmpty else {
                throw AppError(message: "Name cannot be empty.")
            }
            
            guard let email = email, !email.isEmpty else {
                throw AppError(message: "Email cannot be empty.")
            }
            
            try validateUserInput(name: name, email: email)
            
            let address = Address(city: city ?? "N/A", street: street)
            let newUser = UserModel(email: email, name: name, address: address)
            
            userRepository.addLocalUser(newUser)
            
            successSubject.onNext(())
        } catch {
            errorSubject.onNext(error)
        }
    }
}

private extension AddUserViewModel {
    func validateUserInput(name: String, email: String) throws {
        guard userRepository.isValidEmail(email) else {
            throw AppError(message: "Invalid email format.")
        }

        let existingUsers = userRepository.fetchUsers()
        if existingUsers.contains(where: { $0.email == email }) {
            throw AppError(message: "Email is already taken.")
        }
    }
}
