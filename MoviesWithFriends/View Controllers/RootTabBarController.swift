//
//  RootTabBarController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootTabBarController: UITabBarController, UITabBarControllerDelegate {

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
        setupViewControllers()
    }

    private func setup() {
        delegate = self
    }

    private func setupViewControllers() {
        var vcs = [UIViewController]()
        let homeViewController = HomeViewController(mediaManager: mediaManager)
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        vcs.append(homeNavigationController)

        let userViewController = UserViewController(mediaManager: mediaManager)
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        vcs.append(userNavigationController)

        viewControllers = vcs
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return false }

        if index == 1 && Auth.auth().currentUser == nil {
            let authViewController = LoginViewController()
            let authNavigationController = UINavigationController(rootViewController: authViewController)
            present(authNavigationController, animated: true, completion: nil)
            return false
        }
        return true
    }
}
