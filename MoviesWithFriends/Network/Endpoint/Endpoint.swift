//
//  Endpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

protocol Endpoint: CustomStringConvertible {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var httpMethod: String { get }
}

extension Endpoint {
    var scheme: String {
        return "https"
    }

    var httpMethod: String {
        return "GET"
    }
}
