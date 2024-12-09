//
//  AddUserViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 27/11/2024.
//

import Foundation
import RxSwift

protocol AddUserViewModelProtocol {
    var error: Observable<String> { get }
    var success: Observable<Void> { get }
    func addUser(name: String, email: String, city: String?, street: String?)
}

final class AddUserViewModel: AddUserViewModelProtocol {
    private let userRepository: UserRepository
    private let errorSubject = PublishSubject<String>()
    private let successSubject = PublishSubject<Void>()
    private var isErrorOccurred = false
    private let disposeBag = DisposeBag()

    var error: Observable<String> {
        errorSubject.asObservable()
    }

    var success: Observable<Void> {
        successSubject.asObservable()
    }
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func validateUserInput(name: String, email: String, city: String?, street: String?) {
        isErrorOccurred = false
        guard isValidEmail(email) else {
            isErrorOccurred = true
            errorSubject.onNext("Invalid email format.")
            return
        }

        let existingUsers = userRepository.fetchUsers()
        if existingUsers.contains(where: { $0.email == email }) {
            isErrorOccurred = true
            errorSubject.onNext("Email is already taken.")
        }
    }

    func addUser(name: String, email: String, city: String?, street: String?) {
        validateUserInput(name: name, email: email, city: city, street: street)
        
        if isErrorOccurred { return }
        
        let newUser = UserModel(
            email: email,
            name: name,
            address: Address(city: city ?? "N/A", street: street)
        )
        
        userRepository.addLocalUser(newUser)
        
        successSubject.onNext(())
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }
}
