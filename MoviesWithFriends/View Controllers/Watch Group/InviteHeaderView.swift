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

    private let offset: Bool

    init(offset: Bool = true) {
        self.offset = offset
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not used")
    }

    private func setupView() {
        addSubview(containerView)
        containerView.addSubview(headerTitleLabel)

        containerView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(offset ? 12 : 0)
            make.bottom.equalToSuperview().inset(offset ? 12 : 0)
        }

        headerTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(6)
            make.right.equalToSuperview().inset(6)
        }
    }
}
