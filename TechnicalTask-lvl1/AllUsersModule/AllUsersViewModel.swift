//
//  AllUsersViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation
import RxSwift

final class AllUsersViewModel {
    // MARK: - Properties
    private let networkService: NetworkService
    private let networkMonitorService: NetworkMonitorService
    private let userRepository: UserRepository
    private let disposeBag = DisposeBag()
    private let usersSubject = BehaviorSubject<[UserModel]>(value: [])
    private let errorSubject = PublishSubject<Error>()
    
    var users: Observable<[UserModel]> {
        usersSubject.asObservable()
    }
    
    var error: Observable<Error> {
        errorSubject.asObservable()
    }
    
    // MARK: - Life cycle
    init(networkService: NetworkService, networkMonitorService: NetworkMonitorService, userRepository: UserRepository) {
        self.networkService = networkService
        self.networkMonitorService = networkMonitorService
        self.userRepository = userRepository
        
        observeRepositoryErrors()
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
    
    func deleteUser(at indexPath: IndexPath) {
        do {
            var currentUsers = try usersSubject.value()
            guard indexPath.row < currentUsers.count else { return }
            
            let userToDelete = currentUsers[indexPath.row]
            userRepository.deleteUser(userToDelete)
            
            currentUsers.remove(at: indexPath.row)
            usersSubject.onNext(currentUsers)
        } catch {
            errorSubject.onNext(error)
        }
    }
}

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
    
    func observeRepositoryErrors() {
        userRepository.errorPublisher
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                self?.errorSubject.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
