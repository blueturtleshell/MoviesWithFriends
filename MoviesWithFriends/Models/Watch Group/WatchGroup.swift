//
//  WatchGroup.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/29/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct WatchGroup: Equatable, Comparable {
    var id: String
    var name: String
    var type: MediaType
    var mediaID: Int
    var mediaTitle: String
    var posterPath: String?
    var dateInSeconds: Double

    var displayDate: String {
        let date = Date(timeIntervalSince1970: dateInSeconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        return dateFormatter.string(from: date)
    }

    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? String,
            let name = dict["name"] as? String,
            let type = dict["type"] as? String,
            let mediaID = dict["media_id"] as? Int,
            let mediaTitle = dict["media_title"] as? String,
            let dateInSeconds = dict["date"] as? Double else { return nil }

        self.id = id
        self.name = name
        self.type = type == "movie" ? .movie : .tv
        self.mediaID = mediaID
        self.mediaTitle = mediaTitle
        self.posterPath = dict["poster_path"] as? String
        self.dateInSeconds = dateInSeconds
    }

    static func == (lhs: WatchGroup, rhs: WatchGroup) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: WatchGroup, rhs: WatchGroup) -> Bool {
        return lhs.name.lowercased() < rhs.name.lowercased()
    }
}
