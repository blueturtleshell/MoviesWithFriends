//
//  UserView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class UserView: UIView {
    let blurBackgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        return visualEffectView
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.clipsToBounds = true
        return imageView
    }()

    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = .white
        label.contentMode = .center
        label.text = "Full Name"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return button
    }()

    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return button
    }()

    lazy var editProfileSettingsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [editProfileButton, settingsButton])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    let bookmarkSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movies", "TV"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        tableView.separatorColor = UIColor.black
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        backgroundColor = .white
        addSubview(blurBackgroundView)
        blurBackgroundView.contentView.addSubview(profileImageView)
        blurBackgroundView.contentView.addSubview(fullNameLabel)
        blurBackgroundView.contentView.addSubview(editProfileSettingsStackView)
        blurBackgroundView.contentView.addSubview(bookmarkSegmentedControl)
        blurBackgroundView.contentView.addSubview(tableView)

        blurBackgroundView.edgeAnchors == safeAreaLayoutGuide.edgeAnchors

        profileImageView.sizeAnchors == CGSize(width: 100, height: 100)
        profileImageView.leftAnchor == blurBackgroundView.leftAnchor + 12
        profileImageView.topAnchor == blurBackgroundView.topAnchor + 12

        fullNameLabel.leftAnchor == profileImageView.leftAnchor + 12
        fullNameLabel.topAnchor == profileImageView.bottomAnchor + 12

        editProfileSettingsStackView.centerYAnchor == profileImageView.centerYAnchor
        editProfileSettingsStackView.leftAnchor == profileImageView.rightAnchor + 12
        editProfileSettingsStackView.rightAnchor == blurBackgroundView.rightAnchor - 12

        editProfileButton.heightAnchor == 44
        settingsButton.heightAnchor == 44

        bookmarkSegmentedControl.topAnchor == fullNameLabel.bottomAnchor + 12
        bookmarkSegmentedControl.heightAnchor == 44
        bookmarkSegmentedControl.horizontalAnchors == blurBackgroundView.horizontalAnchors + 6

        tableView.topAnchor == bookmarkSegmentedControl.bottomAnchor + 1
        tableView.horizontalAnchors == blurBackgroundView.horizontalAnchors
        tableView.bottomAnchor == blurBackgroundView.bottomAnchor
    }
}
