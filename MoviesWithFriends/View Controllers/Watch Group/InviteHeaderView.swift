//
//  InviteHeaderView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/20/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class InviteHeaderView: UIView {

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Invited"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = .black
        return label
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
        containerView.addSubview(headerTitleLabel)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().inset(12)
        }

        headerTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
        }
    }
}
