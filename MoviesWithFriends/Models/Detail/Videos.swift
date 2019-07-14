//
//  Videos.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct Videos: Decodable {
    let results: [Video]
}

// MARK: - Result
struct Video: Decodable {
    let id, key: String
    let name, site: String
    let size: Int
    let type: String

    enum CodingKeys: String, CodingKey {
        case id, key, name, site, size, type
    }
}
