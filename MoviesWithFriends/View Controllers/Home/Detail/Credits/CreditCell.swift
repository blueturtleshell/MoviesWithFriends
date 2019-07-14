//
//  CreditCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class CreditCell: UITableViewCell {

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        //label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let roleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        //label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
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
        nameLabel.text = nil
        roleLabel.text = nil
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(roleLabel)

        profileImageView.sizeAnchors == CGSize(width: 100, height: 100)
        profileImageView.leftAnchor == leftAnchor + 12
        profileImageView.centerYAnchor == centerYAnchor

        nameLabel.topAnchor == profileImageView.topAnchor + 12
        nameLabel.leftAnchor == profileImageView.rightAnchor + 12
        nameLabel.rightAnchor <= rightAnchor - 16

        roleLabel.leftAnchor == nameLabel.leftAnchor
        roleLabel.rightAnchor == nameLabel.rightAnchor
        roleLabel.bottomAnchor == profileImageView.bottomAnchor - 16
    }
}
