//
//  AuthenticationView.swift
//  KonomuV
//
//  Created by Peter Sun on 7/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class LoginView: UIView {

    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        return button
    }()

    let logoContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return view
    }()

    let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let emailTextField = createTextField(placeholderText: "Enter Email", cornerRadius: 5, keyboardType: .emailAddress)
    let passwordTextField = createTextField(placeholderText: "Enter Password", cornerRadius: 5, isSecure: true)

    var textFields: [UITextField] {
        return [emailTextField, passwordTextField]
    }

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.layer.cornerRadius = 3
        return button
    }()

    lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    let signUpLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        label.text = "Don't have an account?"
        return label
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create one here!", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 12)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 3
        return button
    }()

    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [signUpLabel, signUpButton])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
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
        backgroundColor = .white

        logoContainerView.addSubview(logoImageView)
        addSubview(logoContainerView)
        addSubview(mainStackView)
        addSubview(bottomStackView)
        addSubview(dismissButton)


        dismissButton.sizeAnchors == CGSize(width: 44, height: 44)
        dismissButton.topAnchor == safeAreaLayoutGuide.topAnchor + 12
        dismissButton.leftAnchor == safeAreaLayoutGuide.leftAnchor + 12

        logoContainerView.topAnchor == safeAreaLayoutGuide.topAnchor
        logoContainerView.horizontalAnchors == safeAreaLayoutGuide.horizontalAnchors
        logoContainerView.heightAnchor == 200

        logoImageView.centerAnchors == logoContainerView.centerAnchors

        mainStackView.centerYAnchor == centerYAnchor
        mainStackView.horizontalAnchors == horizontalAnchors + 48

        emailTextField.heightAnchor == 44
        passwordTextField.heightAnchor == 44
        loginButton.heightAnchor == 44

        bottomStackView.bottomAnchor == safeAreaLayoutGuide.bottomAnchor - 12
        bottomStackView.centerXAnchor == centerXAnchor
    }

}
