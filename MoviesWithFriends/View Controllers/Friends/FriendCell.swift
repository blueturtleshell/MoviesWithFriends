//
//  FriendCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/24/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "offWhite")
        view.layer.cornerRadius = 4
        return view
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        return label
    }()

    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        userNameLabel.text = nil
        fullNameLabel.text = nil
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(fullNameLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
        }

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(2)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(2)
            make.left.equalTo(userNameLabel)
            make.right.equalToSuperview().inset(12)
        }
    }
}
