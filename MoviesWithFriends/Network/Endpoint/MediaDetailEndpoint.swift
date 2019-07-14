//
//  MediaDetailEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum MediaDetailEndpoint: Endpoint {
    case tv(id: Int)
    case movie(id: Int)

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .movie(let id):
            return "/3/movie/\(id)"
        case .tv(let id):
            return "/3/tv/\(id)"
        }
    }

    var parameters: [String : Any] {
        switch self {
        case .movie:
            let subRequest = ["videos", "credits", "release_dates"]
            return ["api_key": API.APIKey,
                    "append_to_response": subRequest.joined(separator: ",")]
        case .tv:
            let subRequest = ["videos", "credits", "content_ratings"]
            return ["api_key": API.APIKey,
                    "append_to_response": subRequest.joined(separator: ",")]
        }
    }

    var description: String {
        return "Details"
    }


}
