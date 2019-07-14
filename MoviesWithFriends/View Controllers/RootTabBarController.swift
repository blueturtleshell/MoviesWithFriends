//
//  RootTabBarController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {

    private let mediaManager: MediaManager

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        // fetch user and feed to view controllers
        setupViewControllers()
    }

    private func setup() {

    }

    private func setupViewControllers() {
        let homeViewController = HomeViewController(mediaManager: mediaManager)
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)

        viewControllers = [homeNavigationController]
    }
}
