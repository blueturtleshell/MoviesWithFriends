//
//  WatchGroupState.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/25/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum WatchGroupState {
    case empty
    case editing
    case validWatchGroup(group: WatchGroup)
    case groupCreated
    case noFriendsSelected
    case error(message: String)

    var message: String? {
        switch self {
        case .empty, .editing, .validWatchGroup: return nil
        case .groupCreated: return "Group sent"
        case .noFriendsSelected: return "No friends selected. Press Done again to confirm."
        case .error(let message): return message
        }
    }
}
