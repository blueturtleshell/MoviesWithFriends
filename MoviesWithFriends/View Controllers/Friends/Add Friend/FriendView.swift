//
//  FriendView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/22/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol AddFriendDelegate: class {
    func pasteFromClipboardPressed()
}

class FriendView: UIView {

    let container: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        return stackView
    }()


    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .onDrag
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
        addSubview(container)
        container.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(requestFriendLabel)
        contentView.addSubview(messageLabelContainer)
        messageLabelContainer.addSubview(messageLabel)
        contentView.addSubview(dismissButton)
        contentView.addSubview(friendCodeTextField)
        contentView.addSubview(confirmButton)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(tableView)

        container.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        scrollView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.left.top.right.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.edges.equalToSuperview()
        }

        requestFriendLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
        }

        dismissButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.firstBaseline.equalTo(requestFriendLabel)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }

        messageLabelContainer.snp.makeConstraints { make in
            make.top.equalTo(requestFriendLabel.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }

        messageLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        friendCodeTextField.snp.makeConstraints { make in
            make.top.equalTo(messageLabelContainer.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(confirmButton.snp.left).inset(-12)
            make.height.equalTo(44)
        }

        confirmButton.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.firstBaseline.equalTo(friendCodeTextField)
            make.size.equalTo(CGSize(width: 64, height: 44))
        }

        pasteButton.snp.makeConstraints { make in
            make.width.equalTo(180)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(friendCodeTextField.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(buttonStackView.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().inset(12)
            make.height.equalTo(800)
            make.bottom.equalToSuperview().inset(12)
        }
    }

}
