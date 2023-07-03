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

    lazy var titleSortView: TitleHeaderSortByView = {
        let titleHeader = TitleHeaderSortByView()
        titleHeader.sortByButton.addTarget(self, action: #selector(promptToChangeSort), for: .touchUpInside)
        titleHeader.isUserInteractionEnabled = true
        return titleHeader
    }()

    private let person: PersonDisplayable
    private let mediaManager: MediaManager
    private var media = [Media]()

    private var sortBy: SortBy = .popularityDescending {
        didSet {
            titleSortView.sortByButton.setTitle("Sort by: \(sortBy.display)", for: .normal)
            titleSortView.sizeToFit()
            media = sortMedia(media, by: sortBy)
            self.collectionView.reloadData()
        }
    }

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
        setupView()
        fetchMedia()
    }

    private func setupView() {
        titleSortView.titleLabel.text = person.name
        titleSortView.sortByButton.setTitle("Sort by: \(sortBy.display)", for: .normal)
        titleSortView.sizeToFit()

        navigationItem.titleView = titleSortView
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: mediaSegmentedControl)
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
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
        alertController.popoverPresentationController?.sourceView = titleSortView
        present(alertController, animated: true, completion: nil)
    }

    private func fetchMedia() {
        let endpoint: Endpoint
        if mediaSegmentedControl.selectedSegmentIndex == 0 {
            endpoint = CreditsEndpoint.movie(id: person.id)
        } else {
            endpoint = CreditsEndpoint.tv(id: person.id)
        }

        let searchHUD = HUDView.hud(inView: view, animated: true)
        searchHUD.text = "Searching media"
        searchHUD.accessoryType = .activityIndicator

        mediaManager.mediaWithPerson(endpoint: endpoint) { result in
            do {
                let credits = try result.get()
                searchHUD.remove(from: self.view)
                var mediaSet = Set<Media>(credits.cast)
                mediaSet = mediaSet.union(credits.crew)
                self.media = sortMedia(Array(mediaSet), by: self.sortBy)
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
            let backgroundView = BackgroundLabelView()
            backgroundView.textLabel.text =
            "No \(mediaSegmentedControl.selectedSegmentIndex == 0 ? "Movies" : "TV Shows") featuring\n\(person.name)\nwere found"
            collectionView.backgroundView = backgroundView
            return 0
        }
        collectionView.backgroundView = nil
        return media.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
        cell.posterImageView.layer.cornerRadius = 0

        let mediaItem = media[indexPath.item]
        cell.titleLabel.attributedText = NSAttributedString(string: mediaItem.title, attributes: cell.labelAttributes)

        if let posterPath = mediaItem.posterPath, !posterPath.isEmpty {
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
        if media.isEmpty { return }

        let item = media[indexPath.item]
        let mediaType = mediaSegmentedControl.selectedSegmentIndex == 0 ? MediaType.movie : .tv
        let detailViewController = MediaDetailViewController(mediaType: mediaType, mediaID: item.id, mediaManager: mediaManager)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellWidth = view.bounds.width / 2.0
        let cellHeight = cellWidth * 1.66
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
