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

    var releaseDate: String? {
        let regionReleaseDates = regionReleaseDateInfo.results.filter { $0.regionCode == "US" }.first
        var releaseDate: String?
        if let regionReleaseDates = regionReleaseDates {
            for test in regionReleaseDates.releaseDates {
                let attempt = test.releaseDate
                if !attempt.isEmpty && (test.type == 3 || test.type == 6) { // 3: theater | 6: tv
                    releaseDate = attempt.components(separatedBy: "T").first
                    break
                }
            }
        }
        return releaseDate ?? firstReleaseDate
    }

    private var firstReleaseDate: String?
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

    let popularity: Double?

    let genres: [Genre]

    let credits: Credits

    let videos: Videos

    enum CodingKeys: String, CodingKey {
        case id, title, overview, runtime, genres, videos, credits, popularity
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case firstReleaseDate = "release_date"
        case regionReleaseDateInfo = "release_dates"
        case reviewScore = "vote_average"
    }
}



