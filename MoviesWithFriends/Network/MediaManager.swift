//
//  MediaManager.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation

class MediaManager {
    typealias MediaCompletion = (Result<MediaResult, Error>) -> Void
    typealias MovieDetailCompletion = (Result<MovieDetail, Error>) -> Void

    private let urlSession: URLSession
    private let requestBuilder: RequestBuilder

    init(urlSession: URLSession = URLSession.shared, requestBuilder: RequestBuilder = MediaRequestBuilder()) {
        self.urlSession = urlSession
        self.requestBuilder = requestBuilder
    }

    func fetchMedia(endpoint: Endpoint, page: Int, completion: @escaping MediaCompletion) {
        let request = requestBuilder.buildRequest(endpoint: endpoint, extraParams: ["page": page, "region": "us"])
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

//    func fetchTVShowDetail(id: Int, completion: @escaping MovieDetailCompletion) {
//        let request = requestBuilder.buildRequest(endpoint: MediaDetailEndpoint.movie(id: id), extraParams: nil)
//        fetchHelper(request: request, completion: completion)
//    }

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
//https://api.themoviedb.org/movie/429617?api_key=e29a849bf8131d2edaf7e6127965f161&append_to_response=videos,credits,release_dates
