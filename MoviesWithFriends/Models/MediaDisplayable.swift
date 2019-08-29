//
//  MediaDisplayable.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

protocol MediaDisplayable: Decodable {
    var id: Int { get }
    var title: String { get }
    var posterPath: String? { get }
    var backdropPath: String? { get }
    var overview: String? { get }
    var releaseDate: String? { get }
    var reviewScore: Double? { get }
    var popularity: Double? { get }
}
