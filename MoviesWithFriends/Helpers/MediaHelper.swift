//
//  MediaHelper.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/23/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

func sortMedia(_ media: [Media], by sortBy: SortBy) -> [Media] {
    switch sortBy {
    case .popularityAscending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let popularityA = mediaA.popularity else {
                if let _ = mediaB.releaseDate {
                    return false // A has no popularity but B has, B goes before A
                } else {
                    return mediaA < mediaB // they both have no popularity, compare by name
                }
            }
            guard let popularityB = mediaB.popularity else {
                return true // A has popularity but B does not, A goes before B
            }

            if popularityA == popularityB {
                return mediaA < mediaB // the scores are equal, compare by name
            } else {
                return popularityA < popularityB
            }
        })
    case .popularityDescending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let popularityA = mediaA.popularity else {
                if let _ = mediaB.releaseDate {
                    return true // A has no popularity but B has, B goes before A
                } else {
                    return mediaA > mediaB // they both have no popularity, compare by name
                }
            }
            guard let popularityB = mediaB.popularity else {
                return false // A has popularity but B does not, B goes before A
            }

            if popularityA == popularityB {
                return mediaA > mediaB // the scores are equal, compare by name
            } else {
                return popularityA > popularityB
            }
        })
    case .alphabeticallyAscending:
            return media.sorted(by: <)
    case .alphabeticallyDescending:
            return media.sorted(by: >)
    case .releaseDateAscending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let releaseDateA = mediaA.releaseDate else {
                if let _ = mediaB.releaseDate {
                    return false // A has no release date but B does, B goes before A
                } else {
                    return mediaA < mediaB // they both have no release date, compare by name
                }
            }
            guard let releaseDateB = mediaB.releaseDate else {
                return true // A has a release date but B does not, A goes before B
            }

            if releaseDateA.compare(releaseDateB) == .orderedSame {
                return mediaA < mediaB
            }
            return releaseDateA.compare(releaseDateB) == .orderedAscending
        })
    case .releaseDateDescending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let releaseDateA = mediaA.releaseDate else {
                if let _ = mediaB.releaseDate {
                    return true // A has no release date but B has, A goes before B
                } else {
                    return mediaA > mediaB // they both have no release date, compare by name
                }
            }
            guard let releaseDateB = mediaB.releaseDate else {
                return false // A has a release date but B does not, B goes before A
            }
            if releaseDateA.compare(releaseDateB) == .orderedSame {
                return mediaA > mediaB
            }
            return releaseDateA.compare(releaseDateB) == .orderedDescending
        })
    case .reviewScoreAscending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let reviewScoreA = mediaA.reviewScore else {
                if let _ = mediaB.reviewScore {
                    return false // A has no review score but B has, B goes before A
                } else {
                    return mediaA < mediaB // they both have no review scores, compare by name
                }
            }
            guard let reviewScoreB = mediaB.reviewScore else {
                return true // A has a review score but B does not, A goes before B
            }

            if reviewScoreA == reviewScoreB {
                return mediaA < mediaB
            } else {
                return reviewScoreA < reviewScoreB
            }
        })
    case .reviewScoreDescending:
        return media.sorted(by: { (mediaA, mediaB) -> Bool in
            guard let reviewScoreA = mediaA.reviewScore else {
                if let _ = mediaB.reviewScore {
                    return true // A has no review score but B has, A goes before B
                } else {
                    return mediaA > mediaB // they both have no review scores, compare by name
                }
            }
            guard let reviewScoreB = mediaB.reviewScore else {
                return false // A has a review score but B does not, B goes before A
            }

            if reviewScoreA == reviewScoreB {
                return mediaA > mediaB // the scores are equal, compare by name
            } else {
                return reviewScoreA > reviewScoreB
            }
        })
    }
}
