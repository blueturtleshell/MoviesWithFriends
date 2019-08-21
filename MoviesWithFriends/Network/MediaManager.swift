//
//  MediaManager.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation
import Firebase

class MediaManager {
    typealias MediaCompletion = (Result<MediaResult, Error>) -> Void
    typealias MovieDetailCompletion = (Result<MovieDetail, Error>) -> Void
    typealias TVShowDetailCompletion = (Result<TVShowDetail, Error>) -> Void
    typealias PersonCompletion = (Result<PersonSearch, Error>) -> Void
    typealias PersonCreditsCompletion = (Result<SearchCredits, Error>) -> Void

    private let urlSession: URLSession
    private let requestBuilder: RequestBuilder

    private let db = Firestore.firestore()

    init(urlSession: URLSession = URLSession.shared, requestBuilder: RequestBuilder = MediaRequestBuilder()) {
        self.urlSession = urlSession
        self.requestBuilder = requestBuilder
    }

    func fetchMedia(endpoint: Endpoint, page: Int, completion: @escaping MediaCompletion) {
        let request = requestBuilder.buildRequest(endpoint: endpoint, extraParams: ["page": page, "region": "US"])
        fetchHelper(request: request, completion: completion)
    }

    func fetchRelatedMedia(endpoint: RelatedMediaEndpoint, completion: @escaping MediaCompletion) {
        let request = requestBuilder.buildRequest(endpoint: endpoint, extraParams: nil)
        fetchHelper(request: request, completion: completion)
    }

    func fetchMovieDetail(id: Int, completion: @escaping MovieDetailCompletion) {
        let request = requestBuilder.buildRequest(endpoint: MediaDetailEndpoint.movie(id: id), extraParams: nil)
        fetchHelper(request: request, completion: completion)
    }

    func fetchTVShowDetail(id: Int, completion: @escaping TVShowDetailCompletion) {
        let request = requestBuilder.buildRequest(endpoint: MediaDetailEndpoint.tv(id: id), extraParams: nil)
        fetchHelper(request: request, completion: completion)
    }

    func searchForMovie(text: String, page: Int, completion: @escaping MediaCompletion) {
        let request = requestBuilder.buildRequest(endpoint: SearchEndpoint.movie(text: text), extraParams: ["page": page])
        fetchHelper(request: request, completion: completion)
    }

    func searchForTVShow(text: String, page: Int, completion: @escaping MediaCompletion) {
        let request = requestBuilder.buildRequest(endpoint: SearchEndpoint.tv(text: text), extraParams: ["page": page])
        fetchHelper(request: request, completion: completion)
    }

    func searchForPerson(name: String, page: Int, completion: @escaping PersonCompletion) {
        let request = requestBuilder.buildRequest(endpoint: SearchEndpoint.person(name: name), extraParams: ["page": page])
        fetchHelper(request: request, completion: completion)
    }

    func mediaWithPerson(endpoint: Endpoint, completion: @escaping PersonCreditsCompletion) {
        let request = requestBuilder.buildRequest(endpoint: endpoint, extraParams: nil)
        fetchHelper(request: request, completion: completion)
    }

    func bookmarkMedia(media: MediaDisplayable, mediaType: MediaType, userID: String) {
        let mediaData: [String: Any] = ["id": media.id, "title": media.title,
                                        "poster_path": media.posterPath ?? "",
                                        "type": mediaType == .movie ? 0 : 1]
        db.collection("bookmarks").document(userID).collection("media").document("\(media.id)").setData(mediaData)
    }

    func removeBookmarkMedia(media: MediaDisplayable, userID: String) {
        db.collection("bookmarks").document(userID).collection("media").document("\(media.id)").delete()
    }

    func getImageURL(for imageEndpoint: ImageEndpoint) -> URL? {
        return requestBuilder.buildRequest(endpoint: imageEndpoint, extraParams: nil).url
    }

    private func fetchHelper<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        urlSession.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let results = try jsonDecoder.decode(T.self, from: data)
                        completion(.success(results))
                    } catch {
                        print(error)
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(MediaManagerError.failedRequest))
                }
            }
            }.resume()
    }

    enum MediaManagerError: Error {
        case failedRequest
    }
}
