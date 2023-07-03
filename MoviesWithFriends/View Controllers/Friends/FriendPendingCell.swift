//
//  RequestCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/24/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol FriendPendingCellDelegate: AnyObject {
    func acceptPressed(_ cell: FriendPendingCell)
    func denyPressed(_ cell: FriendPendingCell)
}

class FriendPendingCell: UITableViewCell {

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

    let acceptButton: UIButton = {
        let button = PaddedButton(padding: 12)
        button.setTitle("Accept", for: .normal)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let denyButton: UIButton = {
        let button = PaddedButton(padding: 12)
        button.setTitle("Deny", for: .normal)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [acceptButton, denyButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        return stackView
    }()

    weak var delegate: FriendPendingCellDelegate?

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

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(60)
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(6)
        }

        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(6)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview().inset(12)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(4)
            make.left.equalTo(userNameLabel)
            make.right.lessThanOrEqualToSuperview().inset(12)
        }

        [acceptButton, denyButton].forEach {
            $0.snp.makeConstraints({ make in
                make.width.equalTo(100)
            })
        }

        bottomStackView.snp.makeConstraints { make in
            make.top.equalTo(fullNameLabel.snp.bottom).offset(6)
            make.right.equalToSuperview().inset(12)
        }

        acceptButton.addTarget(self, action: #selector(acceptPressed), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(denyPressed), for: .touchUpInside)
    }

    @objc private func acceptPressed() {
        delegate?.acceptPressed(self)
    }

    @objc private func denyPressed() {
        delegate?.denyPressed(self)
    }
}
