//
//  MediaRowCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/10/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage
import Kingfisher

protocol MediaRowDelegate: AnyObject {
    func didSelectMedia(media: MediaDisplayable)
    func seeAllPressed(endpoint: Endpoint)
}

class MediaRowCell: UITableViewCell {

    var endpoint: Endpoint?
    weak var mediaManager: MediaManager?
    weak var delegate: MediaRowDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()

    let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("See all", for: .normal)
        return button
    }()

    let mediaCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    var media = [MediaDisplayable]() {
        didSet {
            mediaCollectionView.reloadData()
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        seeAllButton.addTarget(self, action: #selector(seeAllPressed), for: .touchUpInside)

        mediaCollectionView.delegate = self
        mediaCollectionView.dataSource = self
        mediaCollectionView.register(NothingFoundCell.self, forCellWithReuseIdentifier: "EmptyCell")
        mediaCollectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")

        addSubview(titleLabel)
        addSubview(seeAllButton)
        addSubview(mediaCollectionView)

        titleLabel.firstBaselineAnchor == seeAllButton.firstBaselineAnchor
        titleLabel.leftAnchor == leftAnchor + 6
        titleLabel.rightAnchor == rightAnchor - 6

        seeAllButton.topAnchor == topAnchor
        seeAllButton.trailingAnchor == trailingAnchor - 6

        mediaCollectionView.topAnchor == titleLabel.bottomAnchor
        mediaCollectionView.bottomAnchor == bottomAnchor
        mediaCollectionView.horizontalAnchors == horizontalAnchors
    }

    @objc private func seeAllPressed(_ sender: UIButton) {
        if let endpoint = endpoint {
            delegate?.seeAllPressed(endpoint: endpoint)
        }
    }
}

extension MediaRowCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if media.count == 0 {
            return 1 // Empty Cell
        }
        return media.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if media.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyCell", for: indexPath) as! NothingFoundCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell
            
            let mediaItem = media[indexPath.item]
            cell.titleLabel.text = mediaItem.title
            if let posterPath = mediaItem.posterPath {
                cell.posterImageView.kf.indicatorType = .activity
                let imageURL = mediaManager?.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
                cell.posterImageView.kf.setImage(with: imageURL)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 135, height: 180)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !media.isEmpty else { return }
        delegate?.didSelectMedia(media: media[indexPath.item])
    }
}

