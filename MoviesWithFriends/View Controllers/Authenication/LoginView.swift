//
//  AuthenticationView.swift
//  KonomuV
//
//  Created by Peter Sun on 7/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

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
        view.backgroundColor = .black
        return view
    }()

    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        return label
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
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
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
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.text = "Don't have an account?"
        label.textColor = .white
        return label
    }()

    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create one here!", for: .normal)
        button.setTitleColor(UIColor(named: "offYellow"), for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14)
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
        backgroundColor = UIColor(named: "backgroundColor")

        logoContainerView.addSubview(logoImageView)
        addSubview(logoContainerView)
        addSubview(errorMessageLabel)
        addSubview(mainStackView)
        addSubview(bottomStackView)
        addSubview(dismissButton)

        dismissButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.top.left.equalTo(safeAreaLayoutGuide).offset(12)
        }

        logoContainerView.snp.makeConstraints { make in
            make.left.top.right.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(180)
        }

        logoImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        errorMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(logoContainerView.snp.bottom).offset(36)
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
        }

        mainStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().inset(48)
        }

        [emailTextField, passwordTextField, loginButton].forEach {
            $0.snp.makeConstraints({ make in
                make.height.equalTo(44)
            })
        }

        bottomStackView.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(12)
            make.centerX.equalToSuperview()
        }
    }

}
