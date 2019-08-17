//
//  BookmarkMedia.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct BookmarkMedia: Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let mediaType: MediaType

    init?(from dict: [String: Any]) {
        guard let id = dict["id"] as? Int,
            let title = dict["title"] as? String,
            let type = dict["type"] as? Int else { return nil }

        self.id = id
        self.title = title
        self.posterPath = dict["poster_path"] as? String
        self.mediaType = type == 0 ? .movie : .tv
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
