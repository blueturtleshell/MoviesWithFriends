//
//  RelationshipState.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/9/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum RelationshipState: String {
    case sendRequest = "Send Request"
    case requestSent = "Request Sent"
    case alreadyFriends = "Unfriend"
    case currentUser = "This is you"
    case blocked = "Blocked" // maybe
}
