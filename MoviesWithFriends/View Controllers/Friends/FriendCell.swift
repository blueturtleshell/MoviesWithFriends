//
//  FriendCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/24/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage


class FriendCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
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

        containerView.edgeAnchors == edgeAnchors + UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        profileImageView.sizeAnchors == CGSize(width: 40, height: 40)
        profileImageView.leftAnchor == leftAnchor + 12
        profileImageView.centerYAnchor == centerYAnchor

        userNameLabel.topAnchor == profileImageView.topAnchor + 2
        userNameLabel.leftAnchor == profileImageView.rightAnchor + 12
        userNameLabel.rightAnchor <= rightAnchor - 12

        fullNameLabel.topAnchor == userNameLabel.bottomAnchor
        fullNameLabel.leftAnchor == userNameLabel.leftAnchor
        fullNameLabel.rightAnchor == rightAnchor - 12
    }
}
