//
//  DefaultRequestBuilder.swift
//  TechnicalTask-lvl1
//
//  Created by Dzmitry Kopats on 25/02/2025.
//

import Foundation

protocol RequestBuilder {
    func buildRequest(for endpoint: Endpoint) -> URLRequest
}

final class DefaultRequestBuilder: RequestBuilder {
    func buildRequest(for endpoint: Endpoint) -> URLRequest {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method
        return request
    }
}
