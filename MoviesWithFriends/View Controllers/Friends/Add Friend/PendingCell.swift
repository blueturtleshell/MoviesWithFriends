//
//  PendingCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/23/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

protocol PendingCellDelegate: AnyObject {
    func cancelPressed(_ cell: PendingCell)
}

class PendingCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
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

    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Awaiting approval"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .black
        label.textAlignment = .right
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [messageLabel, cancelButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        return stackView
    }()

    weak var delegate: PendingCellDelegate?

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
        containerView.addSubview(bottomStackView)

        containerView.edgeAnchors == edgeAnchors + UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)

        profileImageView.sizeAnchors == CGSize(width: 60, height: 60)
        profileImageView.leftAnchor == leftAnchor + 12
        profileImageView.topAnchor == containerView.topAnchor + 6

        userNameLabel.topAnchor == profileImageView.topAnchor + 6
        userNameLabel.leftAnchor == profileImageView.rightAnchor + 12
        userNameLabel.rightAnchor <= rightAnchor - 12

        fullNameLabel.topAnchor == userNameLabel.bottomAnchor + 6
        fullNameLabel.leftAnchor == userNameLabel.leftAnchor
        fullNameLabel.rightAnchor == userNameLabel.rightAnchor

        cancelButton.widthAnchor == 100
        bottomStackView.topAnchor == fullNameLabel.bottomAnchor + 6
        bottomStackView.rightAnchor == containerView.rightAnchor - 12
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
    }


    @objc private func cancelPressed() {
        delegate?.cancelPressed(self)
    }
}
