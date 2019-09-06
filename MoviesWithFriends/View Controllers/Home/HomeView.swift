//
//  HomeView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class HomeView: UIView {

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
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
        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
