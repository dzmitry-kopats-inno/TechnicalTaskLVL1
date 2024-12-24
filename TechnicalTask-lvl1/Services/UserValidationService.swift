//
//  UserValidationService.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 24/12/2024.
//

import Foundation

final class UserValidationService {
    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

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
