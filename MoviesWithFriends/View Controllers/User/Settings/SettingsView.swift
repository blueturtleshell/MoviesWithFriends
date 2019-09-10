//
//  SettingsView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/27/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class SettingsView: UIView {

    private let countryLabel: UILabel = {
        let label = UILabel()
        label.text = "Country"
        label.textColor = .white
        return label
    }()

    let currentCountryLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()

    let changeCountryButton: UIButton = {
        let button = PaddedButton(padding: 12)
        button.setTitle("Change Country", for: .normal)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.layer.cornerRadius = 6
        button.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        return button
    }()

    let bookmarkLabel: UILabel = {
        let label = UILabel()
        label.text = "Bookmarks public"
        label.textColor = .white
        return label
    }()

    let bookmarkSwitch: UISwitch = {
        let bookmarkSwitch = UISwitch()
        bookmarkSwitch.onTintColor = UIColor(named: "offYellow")
        bookmarkSwitch.isOn = false
        return bookmarkSwitch
    }()

    let friendsLabel: UILabel = {
        let label = UILabel()
        label.text = "Friends public"
        label.textColor = .white
        return label
    }()

    let friendsSwitch: UISwitch = {
        let friendSwitch = UISwitch()
        friendSwitch.onTintColor = UIColor(named: "offYellow")
        friendSwitch.isOn = false
        return friendSwitch
    }()

    let watchGroupsLabel: UILabel = {
        let label = UILabel()
        label.text = "Watch Groups public"
        label.textColor = .white
        return label
    }()

    let watchGroupsSwitch: UISwitch = {
        let watchGroupSwitch = UISwitch()
        watchGroupSwitch.onTintColor = UIColor(named: "offYellow")
        watchGroupSwitch.isOn = false
        return watchGroupSwitch
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
        addSubview(countryLabel)
        addSubview(currentCountryLabel)
        addSubview(changeCountryButton)

        addSubview(bookmarkLabel)
        addSubview(bookmarkSwitch)
        addSubview(friendsLabel)
        addSubview(friendsSwitch)
        addSubview(watchGroupsLabel)
        addSubview(watchGroupsSwitch)

        countryLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(48)
            make.left.equalToSuperview().offset(24)
        }

        currentCountryLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(countryLabel)
        }

        changeCountryButton.snp.makeConstraints { make in
            make.top.equalTo(countryLabel.snp.bottom).offset(24)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(44)
        }

        bookmarkLabel.snp.makeConstraints { make in
            make.top.equalTo(changeCountryButton.snp.bottom).offset(48)
            make.left.equalToSuperview().offset(24)
        }

        bookmarkSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(bookmarkLabel)
        }

        friendsLabel.snp.makeConstraints { make in
            make.top.equalTo(bookmarkLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
        }

        friendsSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(friendsLabel)
        }

        watchGroupsLabel.snp.makeConstraints { make in
            make.top.equalTo(friendsLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(24)
        }

        watchGroupsSwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(watchGroupsLabel)
        }
    }
}
