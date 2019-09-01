//
//  UIView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/14/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

extension UIView {
    static func createTextField(placeholderText text: String, cornerRadius: CGFloat,
                                keyboardType: UIKeyboardType = .default, isSecure: Bool = false) -> UITextField {
        let textField = PaddedTextField(padding: 12, cornerRadius: 5)
        textField.placeholder = text
        textField.isSecureTextEntry = isSecure
        textField.backgroundColor = .white
        textField.keyboardType = keyboardType
        textField.returnKeyType = .done
        return textField
    }

    func addShadow(cornerRadius: CGFloat, maskedCorners: CACornerMask, color: UIColor, offset: CGSize, opacity: Float, shadowRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.maskedCorners = maskedCorners
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = shadowRadius
    }
}
