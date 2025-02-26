//
//  URLSessionRequestExecutor.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/02/2025.
//

import Foundation
import RxSwift

protocol RequestExecutor {
    func execute<T: Decodable>(request: URLRequest) -> Observable<T>
}

final class URLSessionRequestExecutor: RequestExecutor {
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(timeout: TimeInterval = 3, decoder: JSONDecoder = JSONDecoder()) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        self.session = URLSession(configuration: configuration)
        self.decoder = decoder
    }
    
    func execute<T: Decodable>(request: URLRequest) -> Observable<T> {
        session.rx.data(request: request)
            .map { data in
                try self.decoder.decode(T.self, from: data)
            }
    }
}
