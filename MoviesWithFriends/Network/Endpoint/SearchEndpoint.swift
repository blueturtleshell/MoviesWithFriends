//
//  SearchEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum SearchEndpoint: Endpoint {
    case movie(text: String)
    case tv(text: String)
    case person(name: String)

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .movie:
            return "/3/search/movie"
        case .tv:
            return "/3/search/tv"
        case .person:
            return "/3/search/person"
        }
    }

    var parameters: [String : Any] {
        var query: String
        switch self {
        case .movie(let text):
            query = text
        case .tv(let text):
            query = text
        case .person(let name):
            query = name
        }
        return ["api_key": API.APIKey, "query": query]
    }

    var description: String {
        return "Search"
    }
}
