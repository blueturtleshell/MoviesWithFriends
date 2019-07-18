//
//  PaddedTextField.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/14/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class PaddedTextField: UITextField {

    private var padding: CGFloat

    init(padding: CGFloat, cornerRadius: CGFloat) {
        self.padding = padding
        super.init(frame: .zero)

        layer.cornerRadius = cornerRadius
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
}
