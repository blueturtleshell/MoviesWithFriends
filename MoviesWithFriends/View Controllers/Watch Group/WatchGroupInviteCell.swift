//
//  WatchGroupInviteCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/19/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol WatchGroupInviteCellDelegate: AnyObject {
    func infoButtonPressed(_ cell: WatchGroupInviteCell)
    func acceptPressed(_ cell: WatchGroupInviteCell)
    func denyPressed(_ cell: WatchGroupInviteCell)
}

class WatchGroupInviteCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "offWhite")
        view.layer.cornerRadius = 4
        return view
    }()

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .black
        return label
    }()

    let invitedLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .black
        return label
    }()

    let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
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

    weak var delegate: WatchGroupInviteCellDelegate?

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
        posterImageView.image = nil
        groupNameLabel.text = nil
        dateLabel.text = nil
        invitedLabel.text = nil
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(invitedLabel)
        
        containerView.addSubview(bottomStackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12))
        }

        posterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 120))
        }

        groupNameLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView)
            make.left.equalTo(posterImageView.snp.right).offset(6)
            make.right.equalToSuperview().inset(6)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(groupNameLabel.snp.bottom).offset(6)
            make.left.equalTo(groupNameLabel)
            make.right.equalToSuperview().inset(6)
        }

        invitedLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(6)
            make.left.equalTo(groupNameLabel)
            make.right.equalToSuperview().inset(6)
        }

        [acceptButton, denyButton].forEach {
            $0.snp.makeConstraints({ make in
                make.width.equalTo(100)
            })
        }

        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalTo(posterImageView).inset(6)
            make.right.equalToSuperview().inset(12)
        }

        let posterTapped = UITapGestureRecognizer(target: self, action: #selector(showMediaInfo))
        posterImageView.addGestureRecognizer(posterTapped)
        acceptButton.addTarget(self, action: #selector(acceptPressed), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(denyPressed), for: .touchUpInside)
    }

    @objc private func showMediaInfo() {
        delegate?.infoButtonPressed(self)
    }

    @objc private func acceptPressed() {
        delegate?.acceptPressed(self)
    }

    @objc private func denyPressed() {
        delegate?.denyPressed(self)
    }
}
