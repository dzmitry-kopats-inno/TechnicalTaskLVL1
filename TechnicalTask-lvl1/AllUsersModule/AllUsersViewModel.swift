//
//  AllUsersViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation
import RxSwift
import Network

protocol AllUsersViewModelProtocol {
    var users: Observable<[UserModel]> { get }
    var error: Observable<Error> { get }
    
    func fetchUsers() -> Completable
    func getUserRepository() -> UserRepositoryProtocol
    func delete(user: UserModel) -> Completable
}

final class AllUsersViewModel: AllUsersViewModelProtocol {
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")
    
    var users: Observable<[UserModel]> {
        return _users.asObservable()
    }
    
    var error: Observable<Error> {
        return _error.asObservable()
    }
    private let _users = BehaviorSubject<[UserModel]>(value: [])
    private let _error = PublishSubject<Error>()
    
    // MARK: - Life cycle
    init(networkService: NetworkServiceProtocol, userRepository: UserRepositoryProtocol) {
        self.networkService = networkService
        self.userRepository = userRepository
        
        observeNetworkChanges()
        loadLocalUsers()
    }
    
    // MARK: - Methods
    func getUserRepository() -> UserRepositoryProtocol {
        userRepository
    }
    
    func fetchUsers() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(NSError(domain: "ViewModel deallocated", code: -1, userInfo: nil)))
                return Disposables.create()
            }
            
            networkService.fetchUsers()
                .subscribe(onNext: { [weak self] users in
                    guard let self else { return }
                    userRepository.update(with: users)
                    loadLocalUsers()
                    completable(.completed)
                }, onError: { [weak self] error in
                    guard let self else { return }
                    _error.onNext(error)
                    completable(.error(error))
                })
                .disposed(by: disposeBag)
            
            return Disposables.create()
        }
    }
    
    func delete(user: UserModel) -> Completable {
        userRepository.deleteUser(user)
            .do(onCompleted: { [weak self] in
                guard let self else { return }
                var currentUsers = try? self._users.value()
                currentUsers?.removeAll { $0.email == user.email }
                if let updatedUsers = currentUsers {
                    self._users.onNext(updatedUsers)
                }
            })
    }
}

// MARK: - Private methods
private extension AllUsersViewModel {
    func loadLocalUsers() {
        let localUsers = userRepository.fetchUsers()
        let sortedUsers = localUsers.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        _users.onNext(sortedUsers)
    }
    
    func observeNetworkChanges() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            if path.status == .satisfied {
                _ = self.fetchUsers()
            } else {
                self.loadLocalUsers()
            }
        }
        monitor.start(queue: queue)
    }
}
