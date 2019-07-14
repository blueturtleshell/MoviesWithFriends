//
//  UserViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class UserViewController: UIViewController {

    let userView: UserView = {
        return UserView()
    }()

    private let mediaManager: MediaManager
    private let userManager: UserManager
    private var user: User?

    init(mediaManager: MediaManager, userManager: UserManager, user: User?) {
        self.mediaManager = mediaManager
        self.userManager = userManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        fetchUser()
    }

    private func setupView() {

    }

    private func fetchUser() {
        
    }
}
