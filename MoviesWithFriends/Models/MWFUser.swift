//
//  User.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct MWFUser {
    private let id: String
    let userName: String
    let profileURL: String?
    let fullName: String?

    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let userName = dict["user_name"] as? String else { return nil }

        self.id = id
        self.userName = userName
        profileURL = dict["profile_url"] as? String
        fullName = dict["full_name"] as? String
    }
}
