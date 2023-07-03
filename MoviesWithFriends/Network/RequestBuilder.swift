//
//  RequestBuilder.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

protocol RequestBuilder {
    func buildRequest(endpoint: Endpoint, extraParams: [String: Any]?) -> URLRequest
}


struct MediaRequestBuilder: RequestBuilder {
    func buildRequest(endpoint: Endpoint, extraParams: [String: Any]? = nil) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = endpoint.scheme
        urlComponents.host = endpoint.host
        urlComponents.path = endpoint.path

        var params = endpoint.parameters
        if let extraParams = extraParams {
            params.merge(extraParams)
        }

        urlComponents.queryItems = params.compactMap { URLQueryItem(name: $0.key, value: "\($0.value)") }
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = endpoint.httpMethod
        return request
    }
}
