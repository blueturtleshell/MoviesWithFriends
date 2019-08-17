//
//  MovieDetail.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct MovieDetail: MediaInfo {
    let id: Int

    let title: String

    let posterPath: String?

    let backdropPath: String?

    let overview: String?

    let releaseDate: String
    let regionReleaseDateInfo: RegionReleaseDates

    let runtime: Int?

    var rating: String? {
        let regionReleaseDates = regionReleaseDateInfo.results.filter { $0.regionCode == "US" }.first
        var certification = "N/A"
        if let regionReleaseDates = regionReleaseDates {
            for test in regionReleaseDates.releaseDates {
                let attempt = test.certification
                if !attempt.isEmpty {
                    certification = attempt
                    break
                }
            }
        }
        return "Rated: \(certification)"
    }

    let reviewScore: Double?

    let genres: [Genre]

    let credits: Credits

    let videos: Videos

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, videos, credits
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case regionReleaseDateInfo = "release_dates"
        case reviewScore = "vote_average"
    }
}



