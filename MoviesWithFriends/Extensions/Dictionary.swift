//
//  Dictionary.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

extension Dictionary {
    mutating func merge(_ dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
