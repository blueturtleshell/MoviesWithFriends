//
//  RelatedMediaEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum RelatedMediaEndpoint: Endpoint {
    case similar(mediaType: MediaType, id: Int)
    case recommended(mediaType: MediaType, id: Int)

    var host: String {
        return API.BaseURL
    }

    var path: String {
        switch self {
        case .similar(let mediaType, let id):
            return "/3/\(mediaType)/\(id)/similar"
        case .recommended(let mediaType, let id):
            return "/3/\(mediaType)/\(id)/recommendations"
        }
    }

    var parameters: [String : Any] {
        return ["api_key": API.APIKey]
    }

    var description: String {
        return "Related Media"
    }
}
