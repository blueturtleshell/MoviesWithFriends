//
//  EmptyCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/20/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class EmptyCell: UITableViewCell {

    let emptyTextLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 2
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
        selectionStyle = .none
        addSubview(emptyTextLabel)

        emptyTextLabel.centerAnchors == centerAnchors
    }
}
