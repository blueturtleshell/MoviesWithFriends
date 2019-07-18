//
//  CreditsEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum CreditsEndpoint: Endpoint {
    case movie(id: Int)
    case tv(id: Int)

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .movie(let id):
            return "/3/person/\(id)/movie_credits"
        case .tv(let id):
            return "/3/person/\(id)/tv_credits"
        }
    }

    var parameters: [String : Any] {
        return ["api_key": API.APIKey]
    }

    var description: String {
        return "Credits"
    }
}
