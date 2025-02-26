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
    private let requestBuilder: RequestBuilder
    private let requestExecutor: RequestExecutor
    
    init(requestBuilder: RequestBuilder = DefaultRequestBuilder(),
         requestExecutor: RequestExecutor = URLSessionRequestExecutor()) {
        self.requestBuilder = requestBuilder
        self.requestExecutor = requestExecutor
    }
    
    func fetchUsers() -> Observable<[UserModel]> {
        let request = requestBuilder.buildRequest(for: .users)
        return requestExecutor.execute(request: request)
    }
}
