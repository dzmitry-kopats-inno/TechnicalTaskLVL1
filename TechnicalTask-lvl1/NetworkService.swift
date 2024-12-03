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

final class NetworkService: NetworkServiceProtocol {
    // MARK: - Properties
    private let session: URLSession
    
    // MARK: - Life cycle
    init(timeout: TimeInterval = 5) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Methods
    func fetchUsers() -> Observable<[UserModel]> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        return performRequest(url: url)
    }
}

// MARK: - Private methods
private extension NetworkService {
    func performRequest<T: Decodable>(url: URL, 
                                      method: String = "GET", 
                                      body: Data? = nil) -> Observable<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        return session.rx.data(request: request)
            .map { data in
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            }
            .catch { error in
                return Observable.error(error)
            }
    }
}
