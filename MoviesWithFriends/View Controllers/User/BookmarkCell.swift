//
//  BookmarkCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class BookmarkCell: UITableViewCell {
        let containerView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor(named: "offWhite")
            view.layer.cornerRadius = 4
            return view
        }()

        let posterImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 3
            imageView.clipsToBounds = true
            return imageView
        }()

        let mediaTitleLabel: UILabel = {
            let label = UILabel()
            label.font = UIFont.preferredFont(forTextStyle: .headline)
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
        }

        private func setupCell() {
            backgroundColor = .clear
            selectionStyle = .none
            addSubview(containerView)
            containerView.addSubview(posterImageView)
            containerView.addSubview(mediaTitleLabel)

            containerView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6))
            }

            posterImageView.snp.makeConstraints { make in
                make.size.equalTo(CGSize(width: 25, height: 40))
                make.left.equalToSuperview().offset(6)
                make.centerY.equalToSuperview()
            }

            mediaTitleLabel.snp.makeConstraints { make in
                make.centerY.equalTo(posterImageView)
                make.left.equalTo(posterImageView.snp.right).offset(12)
                make.right.equalToSuperview().inset(12)
            }
        }
}
