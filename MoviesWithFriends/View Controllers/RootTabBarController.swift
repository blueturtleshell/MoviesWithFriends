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

    lazy var whiteBar: UIView = {
        let bar = UIView()
        bar.frame = self.tabBar.frame
        bar.backgroundColor = .white
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
            configureTabBarItems(hide: false)
            setupViewControllers()
        }
    }

    private func setup() {
        delegate = self

        view.addSubview(whiteBar)
        view.bringSubviewToFront(whiteBar)

        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogin), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserLogout), name: .userDidLogout, object: nil)
    }

    @objc private func handleNoUserFound(_ notification: Notification) {
        setupViewControllers()
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
        }

        let userViewController = UserViewController(user: userManager.currentUser)
        let userNavigationController = UINavigationController(rootViewController: userViewController)
        vcs.append(userNavigationController)

        setViewControllers(vcs, animated: false)
    }


    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if !userManager.isLoggedIn {
            print(viewController)
            if let nav = viewController as? UINavigationController, let _ = nav.viewControllers.first as? UserViewController {
                let authViewController = LoginViewController()
                let authNavigationController = UINavigationController(rootViewController: authViewController)
                present(authNavigationController, animated: true, completion: nil)
                return false
            }
        }
        return true
    }

    private func configureTabBarItems(hide: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.whiteBar.alpha = hide ? 0 : 1
            self.whiteBar.isHidden = hide
        }
    }
}
