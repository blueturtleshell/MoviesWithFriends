//
//  FetchingCVCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/26/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class FetchingCVCell: UICollectionViewCell {

    let fetchLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "offWhite")
        label.text = "Fetching friends"
        label.textAlignment = .right
        return label
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor(named: "offYellow")
        return activityIndicatorView
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
        addSubview(fetchLabel)
        addSubview(activityIndicatorView)

        fetchLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-25)
        }

        activityIndicatorView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(fetchLabel.snp.right).offset(6)
            make.size.equalTo(CGSize(width: 25, height: 25))
        }
    }
}
