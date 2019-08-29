//
//  SortBy.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/23/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum SortBy: Equatable, CaseIterable {
    case popularityAscending
    case popularityDescending
    case releaseDateAscending
    case releaseDateDescending
    case alphabeticallyAscending
    case alphabeticallyDescending
    case reviewScoreAscending
    case reviewScoreDescending

    var display: String {
        switch self {
        case .popularityAscending:
            return "Popularity Asc"
        case .popularityDescending:
            return "Popularity Dsc"
        case .releaseDateAscending:
            return "Release Date Asc"
        case .releaseDateDescending:
            return "Release Date Dsc"
        case .alphabeticallyAscending:
            return "A-Z"
        case .alphabeticallyDescending:
            return "Z-A"
        case .reviewScoreAscending:
            return "Review Score Asc"
        case .reviewScoreDescending:
            return "Review Score Dsc"
        }
    }
}
