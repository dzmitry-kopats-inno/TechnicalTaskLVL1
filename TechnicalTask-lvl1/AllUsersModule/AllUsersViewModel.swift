//
//  AllUsersViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation
import RxSwift

protocol AllUsersViewModelProtocol {
    var users: Observable<[UserModel]> { get }
    var error: Observable<Error> { get }
    
    func fetchUsers()
    func getUserRepository() -> UserRepositoryProtocol
    func delete(user: UserModel) -> Completable
}

class AllUsersViewModel: AllUsersViewModelProtocol {
    private let networkService: NetworkServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()
    
    var users: Observable<[UserModel]> {
        return _users.asObservable()
    }
    
    var error: Observable<Error> {
        return _error.asObservable()
    }
    private let _users = BehaviorSubject<[UserModel]>(value: [])
    private let _error = PublishSubject<Error>()
    
    init(networkService: NetworkServiceProtocol, userRepository: UserRepositoryProtocol) {
        self.networkService = networkService
        self.userRepository = userRepository
        
        loadLocalUsers()
    }
    
    func getUserRepository() -> UserRepositoryProtocol {
        userRepository
    }
    
    func fetchUsers() {
        networkService.fetchUsers()
            .subscribe(onNext: { [weak self] users in
                guard let self else { return }
                userRepository.update(with: users)
                loadLocalUsers()
            }, onError: { [weak self] error in
                guard let self else { return }
                _error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
    
    func delete(user: UserModel) -> Completable {
        userRepository.deleteUser(user)
    }
}

private extension AllUsersViewModel {
    func loadLocalUsers() {
        let localUsers = userRepository.fetchUsers()
        let sortedUsers = localUsers.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        _users.onNext(sortedUsers)
    }
    
}
