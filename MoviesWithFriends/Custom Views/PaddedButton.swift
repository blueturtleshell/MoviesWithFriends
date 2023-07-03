//
//  PaddedButton.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/9/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class PaddedButton: UIButton {

    private let padding: CGFloat

    init(padding: CGFloat = 12) {
        self.padding = padding
        super.init(frame: .zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let baseContentSize = super.intrinsicContentSize
        return CGSize(width: baseContentSize.width + padding, height: baseContentSize.height)
    }
}
