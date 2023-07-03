//
//  Message.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/5/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation
import Firebase

struct Message: Equatable, Comparable {
    let id: String
    let text: String
    let senderID: String
    let timestamp: Timestamp?

    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let text = dict["text"] as? String,
            let senderID = dict["sender_id"] as? String,
            let timestamp = dict["timestamp"] as? Timestamp else { return nil }

        self.id = id
        self.text = text
        self.senderID = senderID
        self.timestamp = timestamp
    }

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        if let lhsTimestamp = lhs.timestamp, let rhsTimestamp = rhs.timestamp {
            return lhsTimestamp.compare(rhsTimestamp) == .orderedAscending
        }
        return true
    }
}
