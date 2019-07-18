//
//  MediaDetailView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class MediaDetailView: UIView {
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isOpaque = false
        return view
    }()

    let backdropImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "bookmark"), for: .normal)
        button.tintColor = .white
        return button
    }()

    let backToPreviousMediaButton: UIButton = {
        let button = UIButton(type: .system)
        button.isHidden = true
        button.setTitle("Go back ...", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "  "
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)
        label.textColor = .white
        return label
    }()

    let certificationLabel: UILabel = {
        let label = UILabel()
        label.text = "  "
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        return label
    }()

    let releaseDateLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        return label
    }()

    let runtimeLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.numberOfLines = 1
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        return label
    }()

    let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "  "
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.textColor = .white
        return label
    }()

    let scoreButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Score", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()

    let creditButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Credits", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()

    let videosButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Videos", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .caption1)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 8
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return button
    }()

    let overviewLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .white
        return label
    }()

    private lazy var movieInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, certificationLabel, releaseDateLabel, runtimeLabel, genreLabel])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [scoreButton, creditButton, videosButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    let relatedTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        return tableView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backdropImageView)
        contentView.addSubview(backToPreviousMediaButton)
        contentView.addSubview(posterImageView)
        contentView.addSubview(bookmarkButton)
        contentView.addSubview(movieInfoStackView)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(relatedTableView)

        containerView.verticalAnchors == safeAreaLayoutGuide.verticalAnchors
        containerView.horizontalAnchors == horizontalAnchors

        scrollView.sizeAnchors == containerView.sizeAnchors
        scrollView.topAnchor == containerView.topAnchor
        scrollView.leadingAnchor == containerView.leadingAnchor

        contentView.widthAnchor == scrollView.widthAnchor
        contentView.edgeAnchors == scrollView.edgeAnchors

        backdropImageView.horizontalAnchors == contentView.horizontalAnchors
        backdropImageView.topAnchor == contentView.topAnchor
        backdropImageView.heightAnchor == 200

        backToPreviousMediaButton.leftAnchor == backdropImageView.leftAnchor + 12
        backToPreviousMediaButton.bottomAnchor == backdropImageView.bottomAnchor - 12
        backToPreviousMediaButton.heightAnchor == 44

        posterImageView.leftAnchor == contentView.leftAnchor + 12
        posterImageView.topAnchor == backdropImageView.bottomAnchor + 12
        posterImageView.sizeAnchors == CGSize(width: 150, height: 200)

        movieInfoStackView.leftAnchor == posterImageView.rightAnchor + 12
        movieInfoStackView.rightAnchor == backdropImageView.rightAnchor - 12
        movieInfoStackView.topAnchor == posterImageView.topAnchor

        buttonStackView.horizontalAnchors == movieInfoStackView.horizontalAnchors
        buttonStackView.topAnchor == movieInfoStackView.bottomAnchor + 12

        bookmarkButton.bottomAnchor == buttonStackView.bottomAnchor + 54
        bookmarkButton.leftAnchor == posterImageView.rightAnchor
        bookmarkButton.sizeAnchors == CGSize(width: 44, height: 66)

        overviewLabel.topAnchor == posterImageView.bottomAnchor + 24
        overviewLabel.horizontalAnchors == contentView.horizontalAnchors + 12

        relatedTableView.topAnchor == overviewLabel.bottomAnchor + 24
        relatedTableView.bottomAnchor == contentView.bottomAnchor - 12
        relatedTableView.horizontalAnchors == contentView.horizontalAnchors + 12
        relatedTableView.heightAnchor == 500
    }
}
