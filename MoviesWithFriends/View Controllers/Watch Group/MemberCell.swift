//
//  MemberCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/3/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MemberCell: UICollectionViewCell {

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        profileImageView.image = nil
    }

    private func setupView() {
        backgroundColor = .clear
        addSubview(profileImageView)

        profileImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
