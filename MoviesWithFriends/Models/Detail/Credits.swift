//
//  Credits.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct Credits: Decodable {
    let cast: [Cast]
    let crew: [Crew]
}

struct Cast: Decodable {
    let character: String
    let id: Int
    let name: String
    let order: Int
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case character, id, name, order
        case profilePath = "profile_path"
    }
}

struct Crew: Decodable {
    let id: Int
    let job: String
    let name: String
    let profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, job, name
        case profilePath = "profile_path"
    }
}
