//
//  TVEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum TVEndpoint: String, Endpoint, CaseIterable {
    case airingToday = "Airing Today"
    case topRated = "Top Rated"
    case onTheAir = "On the Air"
    case popular = "Popular"

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .airingToday: return "/3/tv/airing_today"
        case .topRated: return "/3/tv/top_rated"
        case .onTheAir: return "/3/tv/on_the_air"
        case .popular: return "/3/tv/popular"
        }
    }

    var parameters: [String : Any] {
        return ["api_key": API.APIKey]
    }

    var description: String {
        return self.rawValue
    }
}
