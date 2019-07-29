//
//  WatchGroupViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/25/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class WatchGroupViewController: UIViewController {


    let watchGroupView: WatchGroupView = {
        return WatchGroupView()
    }()

    override func loadView() {
        view = watchGroupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
