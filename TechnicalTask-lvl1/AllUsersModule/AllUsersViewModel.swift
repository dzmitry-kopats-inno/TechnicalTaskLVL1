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
    
    func fetchUsers() -> Completable
    func getUserRepository() -> UserRepository
    func delete(user: UserModel) -> Completable
}

final class AllUsersViewModel: AllUsersViewModelProtocol {
    // MARK: - Properties
    private let networkService: NetworkService
    private let networkMonitorService: NetworkMonitorService
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    
    var users: Observable<[UserModel]> {
        usersSubject.asObservable()
    }
    
    var error: Observable<Error> {
        errorSubject.asObservable()
    }
    private let usersSubject = BehaviorSubject<[UserModel]>(value: [])
    private let errorSubject = PublishSubject<Error>()
    
    // MARK: - Life cycle
    init(networkService: NetworkService, networkMonitorService: NetworkMonitorService, userRepository: UserRepository) {
        self.networkService = networkService
        self.networkMonitorService = networkMonitorService
        self.userRepository = userRepository
        
        observeNetworkChanges()
        loadDataAtStart()
    }
    
    // MARK: - Methods
    func getUserRepository() -> UserRepository {
        userRepository
    }
    
    func fetchUsers() -> Completable {
        return Completable.create { [weak self] completable in
            guard let self else {
                completable(.error(AppError(message: "ViewModel deallocated")))
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
                    errorSubject.onNext(error)
                    loadLocalUsers()
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
                var currentUsers = try? self.usersSubject.value()
                currentUsers?.removeAll { $0.email == user.email }
                if let updatedUsers = currentUsers {
                    self.usersSubject.onNext(updatedUsers)
                }
            })
    }
}

// MARK: - Private methods
private extension AllUsersViewModel {
    func loadDataAtStart() {
        fetchUsers()
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    func loadLocalUsers() {
        let localUsers = userRepository.fetchUsers()
        let sortedUsers = localUsers.sorted {
            $0.name.localizedCompare($1.name) == .orderedAscending
        }
        usersSubject.onNext(sortedUsers)
    }
    
    func observeNetworkChanges() {
        networkMonitorService.isNetworkAvailable
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isAvailable in
                guard let self else { return }
                if isAvailable {
                    _ = self.fetchUsers()
                } else {
                    self.loadLocalUsers()
                }
            })
            .disposed(by: disposeBag)
        
        networkMonitorService.start()
    }
}
