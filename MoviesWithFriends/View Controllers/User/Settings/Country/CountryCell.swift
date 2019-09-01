//
//  RegionCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class CountryCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        textLabel?.textColor = UIColor(named: "offYellow")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented")
    }
}
