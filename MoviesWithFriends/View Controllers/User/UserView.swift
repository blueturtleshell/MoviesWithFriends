//
//  UserView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class UserView: UIView {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.black.withAlphaComponent(0.75).cgColor
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let fullNameLabel: UILabel = createLabel(text: " ", textAlignment: .center)

    private lazy var friendsLabel: UILabel = UIView.createLabel(text: "Friends", textAlignment: .center)
    lazy var friendCountView = PrivateButtonView()

    private lazy var watchGroupsLabel: UILabel = UIView.createLabel(text: "Watch Groups", textAlignment: .center)
    lazy var watchGroupCountView = PrivateButtonView()

    private lazy var friendsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [friendsLabel, friendCountView])
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    private lazy var watchGroupsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [watchGroupsLabel, watchGroupCountView])
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()

    lazy var fullInfoStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [friendsStackView, watchGroupsStackView])
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 24
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
        backgroundColor = UIColor(named: "backgroundColor")
        addSubview(profileImageView)
        addSubview(fullInfoStackView)
        addSubview(fullNameLabel)
        addSubview(bookmarkSegmentedControl)
        addSubview(tableView)

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.left.top.equalTo(safeAreaLayoutGuide).offset(12)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView).offset(12)
            make.top.equalTo(profileImageView.snp.bottom).offset(12)
        }

        fullInfoStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView).inset(18)
            make.centerX.equalToSuperview().offset(56)
            make.right.lessThanOrEqualToSuperview().inset(12)
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
