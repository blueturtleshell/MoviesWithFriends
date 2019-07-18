//
//  MediaInfo.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

protocol MediaInfo: MediaDisplayable {
    var releaseDate: String { get }
    var rating: String? { get }
    var reviewScore: Double? { get }
    var runtime: Int? { get }
    var genres: [Genre] { get }
    var credits: Credits { get }
    var videos: Videos { get }
}
