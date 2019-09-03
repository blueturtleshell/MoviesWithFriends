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

    lazy var bottomBar: UIView = {
        let bar = UIView()
        bar.frame = self.tabBar.frame
        bar.backgroundColor = .black
        return bar
    }()

    private let mediaManager: MediaManager

    private let userManager: UserManager

    init(userManager: UserManager) {
        self.userManager = userManager
        self.mediaManager = MediaManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()

        if let _ = Auth.auth().currentUser {
            userManager.setup()
        } else {
            configureTabBarItems(hide: true)
            setupViewControllers()
        }
    }

    private func setup() {
        delegate = self

        view.addSubview(bottomBar)
        view.bringSubviewToFront(bottomBar)

        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogin), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogout), name: .userDidLogout, object: nil)
    }

    @objc private func handleUserLogin(_ notification: Notification) {
        if let nav = presentedViewController as? UINavigationController,
            let loginViewController = nav.viewControllers.first as? LoginViewController  {
            loginViewController.dismiss(animated: true, completion: nil)
        } else if let nav = presentedViewController as? UINavigationController,
            let signUpViewController = nav.viewControllers.first as? SignUpViewController {
            signUpViewController.dismiss(animated: true, completion: nil)
        }

        let hud = HUDView.hud(inView: view, animated: true)
        hud.text = "Fetching User"
        hud.accessoryType = .activityIndicator
        
        userManager.retrieveUser {
            hud.remove(from: self.view)

            self.configureTabBarItems(hide: true)
            self.setupViewControllers()
        }
    }

    @objc private func handleUserLogout(_ notification: Notification) {
        userManager.logoutUser()
        setupViewControllers()
        selectedIndex = 0
    }

    private func setupViewControllers() {
        var vcs = [UIViewController]()
        let homeViewController = HomeViewController(mediaManager: mediaManager)
        let homeNavigationController = UINavigationController(rootViewController: homeViewController)
        vcs.append(homeNavigationController)

        if let currentUser = userManager.currentUser {
            let watchGroupsViewController = WatchGroupsViewController(user: currentUser)
            let watchGroupsNavigationController = UINavigationController(rootViewController: watchGroupsViewController)
            vcs.append(watchGroupsNavigationController)

            let friendsViewController = FriendsViewController(user: currentUser)
            let friendsNavigationController = UINavigationController(rootViewController: friendsViewController)
            vcs.append(friendsNavigationController)

            let userViewController = UserViewController(user: currentUser)
            let userNavigationController = UINavigationController(rootViewController: userViewController)
            vcs.append(userNavigationController)
        } else {
            let loginPlaceholderViewController = UIViewController()
            loginPlaceholderViewController.tabBarItem = UITabBarItem(title: "Log In", image: #imageLiteral(resourceName: "user"), tag: 99)
            vcs.append(loginPlaceholderViewController)
        }

        setViewControllers(vcs, animated: false)
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 99 && !userManager.isLoggedIn {
            let authViewController = LoginViewController()
            let authNavigationController = UINavigationController(rootViewController: authViewController)
            selectedIndex = 0
            present(authNavigationController, animated: true, completion: nil)
        }
    }

    private func configureTabBarItems(hide: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.bottomBar.alpha = hide ? 0 : 1
            self.bottomBar.isHidden = hide
        }
    }
}
