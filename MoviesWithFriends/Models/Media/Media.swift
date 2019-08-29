//
//  Media.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct Media: Decodable, Comparable, MediaDisplayable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String?
    let reviewScore: Double?
    let releaseDate: String?
    let popularity: Double?

    enum CodingKeys: String, CodingKey {
        case id, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case title
        case releaseDate = "release_date"
        case reviewScore = "vote_average"
        case popularity
    }

    enum TVKeys: String, CodingKey {
        case title = "name"
        case releaseDate = "first_air_date"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)

        if let movieTitle = try? values.decode(String.self, forKey: .title) {
            title = movieTitle
        } else {
            let tvValues = try decoder.container(keyedBy: TVKeys.self)
            title = try tvValues.decode(String.self, forKey: .title)
        }

        if let movieReleaseDate = try? values.decode(String.self, forKey: .releaseDate) {
            releaseDate = movieReleaseDate
        } else {
            let tvValues = try decoder.container(keyedBy: TVKeys.self)
            releaseDate = try? tvValues.decode(String.self, forKey: .releaseDate)
        }

        posterPath = try values.decode(String?.self, forKey: .posterPath)
        backdropPath = try values.decode(String?.self, forKey: .backdropPath)
        overview = try values.decode(String.self, forKey: .overview)
        reviewScore = try values.decode(Double.self, forKey: .reviewScore)
        popularity = try values.decode(Double.self, forKey: .popularity)
    }

    static func < (lhs: Media, rhs: Media) -> Bool {
        return lhs.title.lowercased().compare(rhs.title.lowercased(), locale: .current) == .orderedAscending
    }
}

extension Media: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
