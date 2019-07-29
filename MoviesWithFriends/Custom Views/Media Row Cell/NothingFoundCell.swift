//
//  NoMediaFoundCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/10/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class NothingFoundCell: UICollectionViewCell {

    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Nothing Found"
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .clear
        addSubview(textLabel)

        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
