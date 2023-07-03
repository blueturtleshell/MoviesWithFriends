//
//  FriendRequestCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/5/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol FriendRequestCellDelegate: AnyObject {
    func requestSent(_ cell: FriendRequestCell)
}

class FriendRequestCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "offWhite")
        view.layer.cornerRadius = 12
        return view
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 30
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

    // FIXME: - maybe make image button right centered
    let actionButton: UIButton = {
        let button = PaddedButton(padding: 12)
        button.setTitle("Send Friend Request", for: .normal)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.setTitleColor(UIColor(named: "offWhite"), for: .disabled)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    weak var delegate: FriendRequestCellDelegate?

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
        containerView.addSubview(actionButton)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }

        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(6)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.lessThanOrEqualTo(actionButton.snp.left).offset(12)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.left.equalTo(userNameLabel)
            make.right.lessThanOrEqualTo(actionButton.snp.left).offset(12)
        }

        actionButton.snp.makeConstraints({ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(24)
        })

        actionButton.addTarget(self, action: #selector(sendFriendRequestPressed), for: .touchUpInside)
    }

    @objc private func sendFriendRequestPressed() {
        delegate?.requestSent(self)
    }
}
