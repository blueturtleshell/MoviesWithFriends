//
//  PersonSearch.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct PersonSearch: Decodable {
    var page: Int
    var totalPages: Int
    var results: [Person]

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
    }
}

struct Person: PersonDisplayable, Comparable {
    var id: Int
    var name: String
    var profilePath: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case profilePath = "profile_path"
    }

    static func < (lhs: Person, rhs: Person) -> Bool {
        return lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}
