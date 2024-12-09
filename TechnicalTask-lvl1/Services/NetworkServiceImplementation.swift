//
//  NetworkService.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/11/2024.
//

import Foundation
import RxSwift

protocol NetworkService {
    func fetchUsers() -> Observable<[UserModel]>
}

final class NetworkServiceImplementation: NetworkService {
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Life cycle
    init(timeout: TimeInterval = 5, decoder: JSONDecoder = JSONDecoder()) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.session = URLSession(configuration: configuration)
        self.decoder = decoder
    }
    
    // MARK: - Methods
    func fetchUsers() -> Observable<[UserModel]> {
        let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
        return performRequest(url: url)
    }
}

// MARK: - Private methods
private extension NetworkServiceImplementation {
    func performRequest<T: Decodable>(url: URL, 
                                      method: String = "GET", 
                                      body: Data? = nil) -> Observable<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        return session.rx.data(request: request)
            .map { data in
                let decodedResponse = try self.decoder.decode(T.self, from: data)
                return decodedResponse
            }
            .catch { error in
                return Observable.error(error)
            }
    }
}
