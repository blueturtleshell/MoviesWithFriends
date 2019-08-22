//
//  MediaDetailView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MediaDetailView: UIView {
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let containerView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blur)
        return visualEffectView
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
        imageView.contentMode = .scaleAspectFit
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
        addSubview(backgroundImageView)
        addSubview(containerView)
        containerView.contentView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backdropImageView)
        contentView.addSubview(backToPreviousMediaButton)
        contentView.addSubview(posterImageView)
        contentView.addSubview(movieInfoStackView)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(overviewLabel)
        contentView.addSubview(relatedTableView)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        containerView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundImageView)
        }

        scrollView.snp.makeConstraints { make in
            make.size.equalToSuperview()
            make.left.top.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }

        backdropImageView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(200)
        }

        backToPreviousMediaButton.snp.makeConstraints { make in
            make.left.equalTo(backdropImageView).offset(6)
            make.bottom.equalTo(backdropImageView).inset(6)
            make.height.equalTo(22)
        }

        posterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.top.equalTo(backdropImageView.snp.bottom).offset(12)
            make.size.equalTo(CGSize(width: 150, height: 200))
        }

        movieInfoStackView.snp.makeConstraints { make in
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalTo(backdropImageView).inset(12)
            make.top.equalTo(posterImageView).offset(12)
        }

        buttonStackView.snp.makeConstraints { make in
            make.left.right.equalTo(movieInfoStackView)
            make.top.equalTo(movieInfoStackView.snp.bottom).offset(12)
        }

        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
        }

        relatedTableView.snp.makeConstraints { make in
            make.top.equalTo(overviewLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(12)
            make.height.equalTo(490)
        }
    }
}
