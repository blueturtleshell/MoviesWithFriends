//
//  SignUpView.swift
//  KonomuV
//
//  Created by Peter Sun on 7/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class SignUpView: UIView {

    var textFields: [UITextField] {
        return [userNameTextField, fullNameTextField, emailTextField,
                confirmEmailTextField, passwordTextField, confirmPasswordTextField]
    }

    let avatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "user").withRenderingMode(.alwaysOriginal), for: .normal)
        button.layer.borderWidth = 1
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 44
        button.clipsToBounds = true
        return button
    }()

    let userNameTextField = createTextField(placeholderText: "Enter Username", cornerRadius: 5, keyboardType: .namePhonePad)
    let fullNameTextField = createTextField(placeholderText: "Enter Full Name (optional)", cornerRadius: 5, keyboardType: .namePhonePad)
    let emailTextField = createTextField(placeholderText: "Enter Email", cornerRadius: 5, keyboardType: .emailAddress)
    let confirmEmailTextField = createTextField(placeholderText: "Confirm Email", cornerRadius: 5, keyboardType: .emailAddress)
    let passwordTextField = createTextField(placeholderText: "Enter Password", cornerRadius: 5, isSecure: true)
    let confirmPasswordTextField = createTextField(placeholderText: "Confirm Password", cornerRadius: 5, isSecure: true)

    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        button.layer.cornerRadius = 5
        return button
    }()

    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatarButton, userNameTextField, fullNameTextField, emailTextField,
                                                       confirmEmailTextField, passwordTextField, confirmPasswordTextField, registerButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    let loginLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        return label
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login Here", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 12)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 3
        return button
    }()

    lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [loginLabel, loginButton])
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
        addSubview(stackView)
        addSubview(bottomStackView)

        stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().inset(48)
        }

        avatarButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 88, height: 88))
        }


        [userNameTextField, fullNameTextField, emailTextField, confirmEmailTextField,
         passwordTextField, confirmPasswordTextField, registerButton].forEach {

            $0.snp.makeConstraints({ make in
                make.height.equalTo(44)
                make.width.equalTo(snp.width).multipliedBy(2.0 / 3)
            })
        }

        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            make.centerX.equalToSuperview()
        }
    }
}
