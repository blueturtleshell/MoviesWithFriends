//
//  Media.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct Media: Decodable, MediaDisplayable {
    let id: Int
    let title: String
    let posterPath: String?
    let backdropPath: String?
    let overview: String

    enum CodingKeys: String, CodingKey {
        case id, overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case title
    }

    enum TVKeys: String, CodingKey {
        case title = "name"
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

        posterPath = try values.decode(String?.self, forKey: .posterPath)
        backdropPath = try values.decode(String?.self, forKey: .backdropPath)
        overview = try values.decode(String.self, forKey: .overview)
    }
}

extension Media: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
