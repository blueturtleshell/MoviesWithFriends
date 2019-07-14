//
//  RegionReleaseDates.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct RegionReleaseDates: Decodable {
    let results: [ReleaseDateInfo]
}

struct ReleaseDateInfo: Decodable {
    let regionCode: String
    let releaseDates: [ReleaseDateElement]

    enum CodingKeys: String, CodingKey {
        case regionCode = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct ReleaseDateElement: Decodable {
    let certification: String
    let languageCode: String
    let releaseDate: String
    let type: Int

    enum CodingKeys: String, CodingKey {
        case certification, type
        case languageCode = "iso_639_1"
        case releaseDate = "release_date"
    }
}
