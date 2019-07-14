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

    let overview: String

    let releaseDate: String
    let regionReleaseDateInfo: RegionReleaseDates

    let runtime: Double?

    var rating: String? {
        let regionReleaseDates = regionReleaseDateInfo.results.filter { $0.regionCode == "US" }.first
        var certification = ""
        if regionReleaseDates == nil {
            certification = "NA"
        } else {
            for test in regionReleaseDates!.releaseDates {
                certification = test.certification
                if !certification.isEmpty {
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
