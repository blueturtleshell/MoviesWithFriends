//
//  FetchingCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/25/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class FetchingTBCell: UITableViewCell {

    let fetchLabel: UILabel = {
        let label = UILabel()
        label.text = "Fetching friends"
        label.textAlignment = .right
        return label
    }()

    let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor(named: "offYellow")
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [fetchLabel, activityIndicatorView])
        stackView.axis = .horizontal
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.spacing = 6
        return stackView
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
        addSubview(stackView)

        //fetchLabel.widthAnchor == 130

        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
