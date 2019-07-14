//
//  PosterCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/10/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class PosterCell: UICollectionViewCell {
    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .white
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
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.8).cgColor]
        gradient.locations = [0.70, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: frame.width, height: frame.height)
        posterImageView.layer.insertSublayer(gradient, at: 0)

        addSubview(posterImageView)
        addSubview(titleLabel)

        posterImageView.edgeAnchors == edgeAnchors
        titleLabel.horizontalAnchors == horizontalAnchors + 6
        titleLabel.bottomAnchor == bottomAnchor - 6
    }
}
