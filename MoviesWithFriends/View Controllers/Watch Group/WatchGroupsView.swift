//
//  WatchGroupsView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class WatchGroupsView: UIView {

    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
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
        tableView.backgroundColor = .clear
        addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
