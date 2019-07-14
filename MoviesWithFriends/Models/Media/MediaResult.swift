//
//  MediaResult.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct MediaResult: Decodable {
    let page: Int
    let totalPages: Int
    let totalResults: Int
    let results: [Media]

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalResults = "total_results"
        case totalPages = "total_pages"
    }
}
