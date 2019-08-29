//
//  UserView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class UserView: UIView {
    let blurBackgroundView: BlurBackgroundView = {
        return BlurBackgroundView()
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.black.withAlphaComponent(0.75).cgColor
        imageView.clipsToBounds = true
        return imageView
    }()

    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 16)
        label.textColor = UIColor(named: "offWhite")
        label.contentMode = .center
        label.text = " "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit profile", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return button
    }()

    let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Settings", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.black.withAlphaComponent(0.75)
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
        segmentedControl.tintColor = UIColor(named: "offYellow")
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
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
        addSubview(blurBackgroundView)
        blurBackgroundView.addSubview(profileImageView)
        blurBackgroundView.addSubview(fullNameLabel)
        blurBackgroundView.addSubview(editProfileSettingsStackView)
        blurBackgroundView.addSubview(bookmarkSegmentedControl)
        blurBackgroundView.addSubview(tableView)

        blurBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.left.top.equalToSuperview().offset(12)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView).offset(12)
            make.top.equalTo(profileImageView.snp.bottom).offset(12)
        }

        editProfileSettingsStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView)
            make.left.equalTo(profileImageView.snp.right).offset(36)
            make.right.equalToSuperview().inset(12)
        }

        [editProfileButton, settingsButton].forEach {
            $0.snp.makeConstraints({ make in
                make.height.equalTo(30)
            })
        }

        bookmarkSegmentedControl.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.top.equalTo(fullNameLabel.snp.bottom).offset(12)
            make.left.equalToSuperview().inset(-2)
            make.right.equalToSuperview().offset(2)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(bookmarkSegmentedControl.snp.bottom).offset(1)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
