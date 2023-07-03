//
//  MovieEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum MovieEndpoint: String, Endpoint, CaseIterable {

    case nowPlaying = "Now Playing"
    case topRated = "Top Rated"
    case popular = "Popular"
    case upcoming = "Upcoming"

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .popular: return "/3/movie/popular"
        case .topRated: return "/3/movie/top_rated"
        case .nowPlaying: return "/3/movie/now_playing"
        case .upcoming: return "/3/movie/upcoming"
        }
    }

    var httpMethod: String {
        return "GET"
    }

    var parameters: [String : Any] {
        return ["api_key": API.APIKey]
    }

    var description: String {
        return self.rawValue
    }
}
