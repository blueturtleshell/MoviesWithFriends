//
//  MediaListState.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/23/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

struct MediaListState {
    let mediaType: MediaType
    let endpoint: Endpoint
    var currentPage: Int
    var totalPages: Int

    init(mediaType: MediaType, endpoint: Endpoint) {
        self.mediaType = mediaType
        self.endpoint = endpoint
        currentPage = 1
        totalPages = Int.max
    }

    mutating func updatePages(page: Int, totalPages: Int) {
        self.currentPage = page
        self.totalPages = totalPages
    }

    var canFetchMore: Bool {
        return currentPage < totalPages
    }
}
