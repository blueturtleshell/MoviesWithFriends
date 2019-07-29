//
//  AddUserCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/22/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

protocol AddUserCellDelegate: AnyObject {
    func sendRequestPressed(_ cell: AddUserCell)
    func cancelPressed(_ cell: AddUserCell)
}

class AddUserCell: UITableViewCell {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()

    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        return imageView
    }()

    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let sendRequestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Request", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0,left: 10,bottom: 0,right: 10)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 6
        return button
    }()

    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [sendRequestButton, cancelButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.spacing = 12
        return stackView
    }()

    weak var delegate: AddUserCellDelegate?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        userNameLabel.text = nil
        fullNameLabel.text = nil
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(containerView)
        containerView.addSubview(profileImageView)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(fullNameLabel)
        containerView.addSubview(buttonStackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
        }

        profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.top.left.equalToSuperview().offset(12)
        }


        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView).offset(12)
            make.left.equalTo(profileImageView.snp.right).offset(12)
            make.right.lessThanOrEqualToSuperview()
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).offset(24)
            make.left.right.equalTo(userNameLabel)
        }

        sendRequestButton.snp.makeConstraints { make in
            make.width.equalTo(140)
        }

        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(100)
        }

        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom)
            make.left.equalTo(profileImageView.snp.right).inset(12)
            make.right.equalTo(snp.right).inset(12)
        }

        sendRequestButton.addTarget(self, action: #selector(sendRequestPressed), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
    }

    @objc private func sendRequestPressed() {
        delegate?.sendRequestPressed(self)
    }

    @objc private func cancelPressed() {
        delegate?.cancelPressed(self)
    }
}
