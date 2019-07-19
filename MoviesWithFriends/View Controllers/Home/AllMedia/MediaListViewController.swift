//
//  MediaListViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

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

class MediaListViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {

    private let mediaManager: MediaManager

    private var media = [MediaDisplayable]()

    private var state: MediaListState

    init(mediaManager: MediaManager, mediaType: MediaType, endpoint: Endpoint) {
        self.mediaManager = mediaManager
        state = MediaListState(mediaType: mediaType, endpoint: endpoint)
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        super.init(collectionViewLayout: flowLayout)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchMedia()
    }

    private func setupView() {
        navigationItem.title = state.endpoint.description
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        collectionView.prefetchDataSource = self
    }

    private func fetchMedia() {
        guard state.canFetchMore else { return }

        mediaManager.fetchMedia(endpoint: state.endpoint, page: state.currentPage) { result in
            do {
                let fetchResult = try result.get()
                self.state.updatePages(page: fetchResult.page + 1, totalPages: fetchResult.totalPages)
                self.media += fetchResult.results
                self.collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return media.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

        let item = media[indexPath.item]
        cell.titleLabel.text = item.title
        if let posterPath = item.posterPath, !posterPath.isEmpty {
            cell.posterImageView.kf.indicatorType = .activity
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            cell.posterImageView.kf.setImage(with: imageURL)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = media[indexPath.item]
        let detailViewController = MediaDetailViewController(mediaType: state.mediaType, mediaID: item.id, mediaManager: mediaManager)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        attemptToFetchNewMedia(indexPaths: indexPaths, media: media)
    }

    func attemptToFetchNewMedia(indexPaths: [IndexPath], media: [MediaDisplayable]) {
        let containedIndexPathItems = indexPaths.filter { $0.item == media.count - 1}.count
        if containedIndexPathItems > 0 {
            fetchMedia()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = view.bounds.width / 2.0
        let cellHeight = cellWidth * 1.66
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
