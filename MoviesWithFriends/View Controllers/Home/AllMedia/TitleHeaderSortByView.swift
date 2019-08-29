//
//  TitleHeaderSortByView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/22/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class TitleHeaderSortByView: UIView {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textColor = UIColor(named: "offYellow")
        return label
    }()

    let sortByButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sort:", for: .normal)
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, sortByButton])
        stackView.spacing = -6
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = true
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
}
