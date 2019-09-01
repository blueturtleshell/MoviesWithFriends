//
//  Country.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct Country: Decodable, Comparable {
    let name: String
    let countryCode: String

    enum CodingKeys: String, CodingKey {
        case name = "english_name"
        case countryCode = "iso_3166_1"
    }

    func toDict() -> [String: String] {
        return ["countryName": name, "countryCode": countryCode]
    }

    static func < (lhs: Country, rhs: Country) -> Bool {
        return lhs.name.localizedCompare(rhs.name) == .orderedAscending
    }
}
