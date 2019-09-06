//
//  PrivateButtonView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/4/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class PrivateButtonView: UIView {

    lazy var countButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(named: "offYellow")
        button.setTitle("   ", for: .normal)
        button.setTitleColor(UIColor(named: "offWhite"), for: .disabled)
        return button
    }()

    private lazy var lockImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "lock"))
        imageView.tintColor = UIColor(named: "offYellow")
        imageView.isHidden = true
        return imageView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [countButton, lockImageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
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
        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func configure(count: Int, isPublic: Bool) {
        countButton.setTitle("\(count)", for: .normal)
        countButton.isEnabled = isPublic && count > 0
        lockImageView.isHidden = isPublic
    }
}
