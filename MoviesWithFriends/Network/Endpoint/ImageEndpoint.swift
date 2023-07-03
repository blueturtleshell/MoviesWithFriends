//
//  ImageEndpoint.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

enum ImageEndpoint: Endpoint {
    case poster(path: String, size: PosterSize)
    case backdrop(path: String, size: BackdropSize)
    case profile(path: String, size: ProfileSize)

    var host: String {
        return API.BaseImageURL
    }

    var path: String {
        switch self {
        case .poster(let path, let size): return   "/t/p/\(size.rawValue)\(path)"
        case .backdrop(let path, let size): return "/t/p/\(size.rawValue)\(path)"
        case .profile(let path, let size): return  "/t/p/\(size.rawValue)\(path)"
        }
    }

    var parameters: [String : Any] {
        return [:]
    }

    var description: String {
        return "Image"
    }

    enum PosterSize: String {
        case small = "w185"
        case medium = "w500"
        case large = "w780"
        case original
    }

    enum BackdropSize: String {
        case small = "w300"
        case medium = "w780"
        case large = "w1280"
        case original
    }

    enum ProfileSize: String {
        case small = "w45"
        case medium = "w185"
        case large = "h632"
        case original
    }
}
