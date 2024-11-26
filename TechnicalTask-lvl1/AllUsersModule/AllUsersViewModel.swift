//
//  AllUsersViewModel.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import RxSwift
import RxCocoa

protocol AllUsersViewModelProtocol {
    var users: Observable<[UserModel]> { get }
    var error: Observable<Error> { get }
    
    func fetchUsers()
}

class AllUsersViewModel: AllUsersViewModelProtocol {
    private let networkService: NetworkService
    private let disposeBag = DisposeBag()
    
    var users: Observable<[UserModel]> {
        return _users.asObservable()
    }
    
    var error: Observable<Error> {
        return _error.asObservable()
    }
    
    private let _users = PublishSubject<[UserModel]>()
    private let _error = PublishSubject<Error>()
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    func fetchUsers() {
        networkService.fetchUsers()
            .subscribe(onNext: { [weak self] users in
                self?._users.onNext(users)
            }, onError: { [weak self] error in
                self?._error.onNext(error)
            })
            .disposed(by: disposeBag)
    }
}
