//
//  NetworkService.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation
import RxSwift

protocol NetworkServiceProtocol {
    func fetchUsers() -> Observable<[UserModel]>
}

class NetworkService: NetworkServiceProtocol {
    func fetchUsers() -> Observable<[UserModel]> {
        // TODO: - Improve logic
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .map { data in
                let users = try? JSONDecoder().decode([UserModel].self, from: data)
                return users ?? []
            }
    }
}
