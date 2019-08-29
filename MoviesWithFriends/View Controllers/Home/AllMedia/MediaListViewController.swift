//
//  MediaListViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MediaListViewController: UICollectionViewController, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {

    lazy var titleSortView: TitleHeaderSortByView = {
        let titleHeader = TitleHeaderSortByView()
        titleHeader.sortByButton.addTarget(self, action: #selector(promptToChangeSort), for: .touchUpInside)
        titleHeader.isUserInteractionEnabled = true
        return titleHeader
    }()

    private let mediaManager: MediaManager

    private var media = [Media]()

    private var state: MediaListState
    private var sortBy: SortBy = .popularityDescending {
        didSet {
            titleSortView.sortByButton.setTitle("Sort by: \(sortBy.display)", for: .normal)
            titleSortView.sizeToFit()
            media = sortMedia(media, by: sortBy)
            self.collectionView.reloadData()
        }
    }

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
        titleSortView.titleLabel.text = state.endpoint.description
        titleSortView.sortByButton.setTitle("Sort by: \(sortBy.display)", for: .normal)
        titleSortView.sizeToFit()
        navigationItem.titleView = titleSortView

        collectionView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        collectionView.prefetchDataSource = self
    }

    @objc private func promptToChangeSort() {
        let alertController = UIAlertController(title: "Sorty By", message: nil, preferredStyle: .actionSheet)

        SortBy.allCases.forEach { sortMethod in
            let action = UIAlertAction(title: sortMethod.display, style: .default, handler: { alertAction in
                guard self.sortBy != sortMethod else {
                    return
                }
                self.sortBy = sortMethod
            })

            alertController.addAction(action)

            if self.sortBy == sortMethod {
                alertController.preferredAction = action
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func fetchMedia() {
        guard state.canFetchMore else { return }

        mediaManager.fetchMedia(endpoint: state.endpoint, page: state.currentPage) { result in
            do {
                let fetchResult = try result.get()
                self.state.updatePages(page: fetchResult.page + 1, totalPages: fetchResult.totalPages)
                self.media += fetchResult.results
                self.media = sortMedia(self.media, by: self.sortBy)
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
        cell.posterImageView.layer.cornerRadius = 0
        let item = media[indexPath.item]
        cell.titleLabel.attributedText = NSAttributedString(string: item.title, attributes: cell.labelAttributes)
        if let posterPath = item.posterPath, !posterPath.isEmpty {
            cell.posterImageView.contentMode = .scaleAspectFill
            cell.posterImageView.kf.indicatorType = .activity
            let activity = cell.posterImageView.kf.indicator?.view as! UIActivityIndicatorView
            activity.color = UIColor(named: "offYellow")
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            cell.posterImageView.kf.setImage(with: imageURL)
        } else {
            cell.posterImageView.contentMode = .scaleAspectFit
            cell.posterImageView.image = #imageLiteral(resourceName: "profile_na")
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
