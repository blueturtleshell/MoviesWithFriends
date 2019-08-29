//
//  SettingsView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/27/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class SettingsView: UIView {

    let regionLabel: UILabel = {
        let label = UILabel()
        label.text = "Region"
        label.textColor = .white
        return label
    }()

    let currentRegionLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()

    let changeRegionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Region", for: .normal)
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
        friendSwitch.isOn = false
        return friendSwitch
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
        addSubview(regionLabel)
        addSubview(currentRegionLabel)
        addSubview(changeRegionButton)

        addSubview(bookmarkLabel)
        addSubview(bookmarkSwitch)
        addSubview(friendsLabel)
        addSubview(friendsSwitch)

        regionLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(48)
            make.left.equalToSuperview().offset(24)
        }

        currentRegionLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(24)
            make.centerY.equalTo(regionLabel)
        }

        changeRegionButton.snp.makeConstraints { make in
            make.top.equalTo(regionLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 44))
        }

        bookmarkLabel.snp.makeConstraints { make in
            make.top.equalTo(changeRegionButton.snp.bottom).offset(24)
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
    }
}
