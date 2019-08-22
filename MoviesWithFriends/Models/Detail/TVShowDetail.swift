//
//  TVShowDetail.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct TVShowDetail: MediaInfo {

    var id: Int

    var title: String

    var posterPath: String?

    var backdropPath: String?

    var overview: String?

    var releaseDate: String?

    var rating: String? {
        let regionRating = contentRatings.results.filter { $0.regionCode == "US" }.first
        var certification = ""

        if let regionRating = regionRating {
            certification = regionRating.rating
        } else {
            certification = "NA"
        }
        return "Rated: \(certification)"
    }

    private var contentRatings: ContentRatings
    var reviewScore: Double?

    var runtime: Int? {
        return tvRunTime?.first
    }

    var tvRunTime: [Int]?

    var genres: [Genre]

    var credits: Credits

    var videos: Videos

    enum CodingKeys: String, CodingKey {
        case id, overview, credits, videos, genres
        case title = "name"
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case tvRunTime = "episode_run_time"
        case releaseDate = "first_air_date"
        case reviewScore = "vote_average"
        case contentRatings = "content_ratings"
    }
}

struct ContentRatings: Decodable {
    let results: [ContentRatingsResult]
}

struct ContentRatingsResult: Decodable {
    let regionCode: String
    let rating: String

    enum CodingKeys: String, CodingKey {
        case regionCode = "iso_3166_1"
        case rating
    }
}
