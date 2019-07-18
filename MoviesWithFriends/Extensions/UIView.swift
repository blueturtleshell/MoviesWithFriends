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
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.03)
        textField.keyboardType = keyboardType
        textField.returnKeyType = .done
        return textField
    }
}
