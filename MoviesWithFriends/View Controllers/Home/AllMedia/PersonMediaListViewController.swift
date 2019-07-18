//
//  MixedMediaListViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit


class PersonMediaListViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    lazy var mediaSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movie", "TV"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(mediaSegmentedControlChanged), for: .valueChanged)
        return segmentedControl
    }()

    private let person: PersonDisplayable
    private let mediaManager: MediaManager
    private var media = [MediaDisplayable]()

    init(person: PersonDisplayable, mediaManager: MediaManager) {
        self.person = person
        self.mediaManager = mediaManager
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

        navigationItem.title = person.name

        setupView()

        fetchMedia()
    }

    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mediaSegmentedControl)


        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        collectionView.register(NothingFoundCell.self, forCellWithReuseIdentifier: "NothingFoundCell")
    }

    private func fetchMedia() {
        let endpoint: Endpoint
        if mediaSegmentedControl.selectedSegmentIndex == 0 {
            endpoint = CreditsEndpoint.movie(id: person.id)
        } else {
            endpoint = CreditsEndpoint.tv(id: person.id)
        }

        mediaManager.mediaWithPerson(endpoint: endpoint) { result in
            do {
                let credits = try result.get()

                var mediaSet = Set<Media>(credits.cast)
                mediaSet = mediaSet.union(credits.crew)

                self.media = Array(mediaSet).sorted { $0.title < $1.title }
                self.collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    @objc private func mediaSegmentedControlChanged(_ segmentedControl: UISegmentedControl) {
        fetchMedia()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if media.isEmpty {
            return 1
        }
        return media.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if media.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NothingFoundCell", for: indexPath) as! NothingFoundCell
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

        let mediaItem = media[indexPath.item]
        cell.titleLabel.text = mediaItem.title

        if let posterPath = mediaItem.posterPath {
            cell.posterImageView.kf.indicatorType = .activity
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            cell.posterImageView.kf.setImage(with: imageURL)
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if media.isEmpty { return }

        let item = media[indexPath.item]
        let mediaType = mediaSegmentedControl.selectedSegmentIndex == 0 ? MediaType.movie : .tv
        let detailViewController = MediaDetailViewController(mediaType: mediaType, mediaID: item.id, mediaManager: mediaManager)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        if media.isEmpty {
            return CGSize(width: view.bounds.width, height: 200)
        }

        let cellWidth = view.bounds.width / 2.0
        let cellHeight = cellWidth * 1.66
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
