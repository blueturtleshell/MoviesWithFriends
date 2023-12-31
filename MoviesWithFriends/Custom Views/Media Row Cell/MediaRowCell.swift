//
//  MediaRowCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/10/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Kingfisher

protocol MediaRowDelegate: AnyObject {
    func didSelectMedia(media: MediaDisplayable)
    func seeAllPressed(endpoint: Endpoint)
}

class MediaRowCell: UITableViewCell {

    var endpoint: Endpoint?
    weak var mediaManager: MediaManager?
    weak var delegate: MediaRowDelegate?
    var isFetching = false

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "offWhite")
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        return label
    }()

    let seeAllButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.setTitle("See all", for: .normal)
        return button
    }()

    let mediaCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
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
        mediaCollectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")

        addSubview(titleLabel)
        addSubview(seeAllButton)
        addSubview(mediaCollectionView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(6)
            make.left.right.equalToSuperview().inset(6)
        }

        seeAllButton.snp.makeConstraints { make in
            make.firstBaseline.equalTo(titleLabel)
            make.right.equalToSuperview().inset(6)
        }

        mediaCollectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
    }

    @objc private func seeAllPressed(_ sender: UIButton) {
        if let endpoint = endpoint, media.count > 0 {
            delegate?.seeAllPressed(endpoint: endpoint)
        }
    }
}

extension MediaRowCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if media.isEmpty && !isFetching {
            collectionView.isScrollEnabled = false
            let backgroundView = BackgroundLabelView()
            backgroundView.textLabel.text = "No results found"
            collectionView.backgroundView = backgroundView
            return 0
        } else if isFetching {
            collectionView.isScrollEnabled = false
            let backgroundView = BackgroundLabelView()
            backgroundView.textLabel.text = "Fetching"
            collectionView.backgroundView = backgroundView
            return 0
        }

        collectionView.backgroundView = nil
        collectionView.isScrollEnabled = true
        return media.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

        cell.addShadow(cornerRadius: 4, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner], color: .black, offset: CGSize(width: 2, height: 2), opacity: 0.25, shadowRadius: 3)

        let mediaItem = media[indexPath.item]
        cell.titleLabel.attributedText = NSAttributedString(string: mediaItem.title, attributes: cell.labelAttributes)
        if let posterPath = mediaItem.posterPath, !posterPath.isEmpty {
            cell.posterImageView.kf.indicatorType = .activity
            let activity = cell.posterImageView.kf.indicator?.view as! UIActivityIndicatorView
            activity.color = UIColor(named: "offYellow")
            let imageURL = mediaManager?.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            cell.posterImageView.kf.setImage(with: imageURL)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 135, height: 190)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !media.isEmpty else { return }
        delegate?.didSelectMedia(media: media[indexPath.item])
    }
}

