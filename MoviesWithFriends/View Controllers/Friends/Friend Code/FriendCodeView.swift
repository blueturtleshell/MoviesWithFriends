//
//  FriendCodeView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class FriendCodeView: UIView {

    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = #colorLiteral(red: 0.1215076372, green: 0.1377719343, blue: 0.1489635408, alpha: 1)
        containerView.layer.cornerRadius = 6
        containerView.clipsToBounds = true
        return containerView
    }()

    private let displayLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Code"
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()

    private let friendCodeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    let friendCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "Friend Code goes here"
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textAlignment = .center
        label.textColor = .white
        label.minimumScaleFactor = 0.6
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Copy to Clipboard", for: .normal)
        return button
    }()

    let qrCodeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
        addSubview(containerView)
        containerView.addSubview(displayLabel)
        containerView.addSubview(friendCodeContainer)
        friendCodeContainer.addSubview(friendCodeLabel)
        containerView.addSubview(copyButton)
        containerView.addSubview(qrCodeImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

        friendCodeContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(36)
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }

        friendCodeLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12))
        }

        copyButton.snp.makeConstraints { make in
            make.top.equalTo(friendCodeContainer.snp.bottom).offset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
        }

        qrCodeImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 115, height: 115))
        }
    }

}
