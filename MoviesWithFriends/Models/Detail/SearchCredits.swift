//
//  SearchCredits.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct SearchCredits: Decodable {
    let cast: [Media]
    let crew: [Media]
}
