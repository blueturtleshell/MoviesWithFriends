//
//  TableViewBackgroundLabelView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/6/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class BackgroundLabelView: UIView {

    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "No Bookmarks Found"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor(named: "offWhite")
        label.font = UIFont(name: "AvenirNext-Bold", size: 24)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        addSubview(textLabel)

        textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
