//
//  FriendView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/22/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

protocol AddFriendDelegate: class {
    func pasteFromClipboardPressed()
}

class FriendView: UIView {

    let blurBackgroundView: UIVisualEffectView = {
        let blur = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blur)
        return visualEffectView
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    let requestFriendLabel: UILabel = {
        let label = UILabel()
        label.text = "Request Friend"
        label.textColor = .white
        return label
    }()

    let messageLabelContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("X", for: .normal)
        button.tintColor = .white
        return button
    }()

    let friendCodeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Friend Code"
        textField.autocapitalizationType = .none
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return textField
    }()

    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let pasteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Paste from clipboard", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let qrCodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("QR Code", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pasteButton, qrCodeButton])
        stackView.axis = .horizontal
        stackView.distribution = UIStackView.Distribution.fillProportionally
        stackView.spacing = 12
        return stackView
    }()


    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        return tableView
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
        addSubview(blurBackgroundView)
        blurBackgroundView.contentView.addSubview(scrollView)
        scrollView.addSubview(requestFriendLabel)
        scrollView.addSubview(messageLabelContainer)
        messageLabelContainer.addSubview(messageLabel)
        scrollView.addSubview(dismissButton)
        scrollView.addSubview(friendCodeTextField)
        scrollView.addSubview(confirmButton)
        scrollView.addSubview(buttonStackView)
        scrollView.addSubview(tableView)

        blurBackgroundView.topAnchor == safeAreaLayoutGuide.topAnchor
        blurBackgroundView.horizontalAnchors == horizontalAnchors
        blurBackgroundView.bottomAnchor == bottomAnchor

        scrollView.topAnchor == blurBackgroundView.topAnchor
        scrollView.horizontalAnchors == blurBackgroundView.horizontalAnchors
        scrollView.heightAnchor == blurBackgroundView.heightAnchor

        requestFriendLabel.topAnchor == scrollView.topAnchor + 12
        requestFriendLabel.centerXAnchor == scrollView.centerXAnchor

        dismissButton.leftAnchor == scrollView.leftAnchor + 12
        dismissButton.lastBaselineAnchor == requestFriendLabel.lastBaselineAnchor
        dismissButton.sizeAnchors == CGSize(width: 44, height: 44)

        messageLabelContainer.topAnchor == requestFriendLabel.bottomAnchor + 24
        messageLabelContainer.horizontalAnchors == horizontalAnchors
        messageLabelContainer.heightAnchor == 44

        messageLabel.centerAnchors == messageLabelContainer.centerAnchors

        friendCodeTextField.topAnchor == messageLabelContainer.bottomAnchor + 24
        friendCodeTextField.leftAnchor == scrollView.leftAnchor + 12
        friendCodeTextField.rightAnchor == confirmButton.leftAnchor - 12
        friendCodeTextField.heightAnchor == 44

        confirmButton.rightAnchor == rightAnchor - 12
        confirmButton.widthAnchor == 64
        confirmButton.heightAnchor == 44
        confirmButton.lastBaselineAnchor == friendCodeTextField.lastBaselineAnchor

        pasteButton.widthAnchor == 180
        buttonStackView.topAnchor == friendCodeTextField.bottomAnchor + 24
        buttonStackView.centerXAnchor == centerXAnchor
        buttonStackView.heightAnchor == 44

        tableView.topAnchor == buttonStackView.bottomAnchor + 24
        tableView.horizontalAnchors == horizontalAnchors + 12
        tableView.heightAnchor == 800
        tableView.bottomAnchor <= scrollView.bottomAnchor - 12
    }

}
