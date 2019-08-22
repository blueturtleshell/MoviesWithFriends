//
//  CreditBackgroundView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/21/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class CreditBackgroundView: UIView {

    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Aqualicious"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let blurBackground: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blur)
        return visualEffectView
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
        addSubview(backgroundImageView)
        addSubview(blurBackground)

        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        blurBackground.snp.makeConstraints { make in
            make.edges.equalTo(backgroundImageView)
        }
    }
}
