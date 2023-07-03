//
//  MediaType.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum MediaType: String {
    case movie
    case tv

    var endpoints: [Endpoint] {
        switch self {
        case .movie: return MovieEndpoint.allCases
        case .tv: return TVEndpoint.allCases
        }
    }
}
