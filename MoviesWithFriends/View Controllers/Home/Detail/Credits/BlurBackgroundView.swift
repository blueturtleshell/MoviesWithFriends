//
//  CreditBackgroundView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/21/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class BlurBackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = UIColor(named: "backgroundColor")
    }

}
