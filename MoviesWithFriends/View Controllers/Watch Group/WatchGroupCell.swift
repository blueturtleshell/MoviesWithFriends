//
//  WatchGroupCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

protocol WatchGroupCellDelegate: AnyObject {
    func infoButtonPressed(_ cell: WatchGroupCell)
}

class WatchGroupCell: UITableViewCell {

    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 4
        container.clipsToBounds = true
        return container
    }()

    let movieNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)

        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        return label
    }()

    weak var delegate: WatchGroupCellDelegate?

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
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(movieNameLabel)
        containerView.addSubview(dateLabel)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        posterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 120))
        }

        groupNameLabel.snp.makeConstraints { make in
            make.bottom.equalTo(movieNameLabel.snp.top).offset(-12)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        movieNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(posterImageView)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(movieNameLabel.snp.bottom).offset(12)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }
    }
}
