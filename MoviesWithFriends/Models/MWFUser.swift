//
//  User.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct MWFUser: Equatable, Comparable {
    let id: String
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

    static func == (lhs: MWFUser, rhs: MWFUser) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: MWFUser, rhs: MWFUser) -> Bool {
        return lhs.userName.lowercased() < rhs.userName.lowercased()
    }
}

extension MWFUser: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
