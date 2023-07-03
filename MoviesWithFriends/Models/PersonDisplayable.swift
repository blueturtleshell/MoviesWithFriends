//
//  PersonDisplayable.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

protocol PersonDisplayable: Decodable {
    var id: Int  { get }
    var name: String  { get }
    var profilePath: String? { get }
}
