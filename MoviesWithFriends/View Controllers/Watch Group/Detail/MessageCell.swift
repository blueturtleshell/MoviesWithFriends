//
//  MessageCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/8/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 4
        container.clipsToBounds = true
        return container
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    let userNameLabel: UILabel = {
        let label = UILabel()
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

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(containerView)
        containerView.addSubview(messageLabel)
        containerView.addSubview(divider)
        containerView.addSubview(profileImageView)
        containerView.addSubview(userNameLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(6)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
        }

        divider.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }

        profileImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.top.equalTo(messageLabel.snp.bottom).offset(6)
            make.bottom.equalToSuperview().inset(6)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }

        userNameLabel.snp.makeConstraints { make in
            make.left.equalTo(profileImageView.snp.right).offset(6)
            make.right.lessThanOrEqualToSuperview().inset(6)
            make.centerY.equalTo(profileImageView)
        }
    }
}
