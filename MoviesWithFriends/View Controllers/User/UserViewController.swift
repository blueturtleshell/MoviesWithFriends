//
//  UserViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController {

    let userView: UserView = {
        return UserView()
    }()

    private let mediaManager: MediaManager
    private var user: MWFUser? {
        didSet {
            if let user = user {
                configureView(for: user)
            }
        }
    }

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "User", image: UIImage(named: "user"), tag: 1)
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
        NotificationCenter.default.addObserver(self, selector: #selector(fetchUser), name: .userDidLogin, object: nil)
    }

    @objc private func fetchUser(_ notification: Notification? = nil) {
        guard let userID = Auth.auth().currentUser?.uid, user == nil else { return }

        Firestore.firestore().collection("users").document(userID).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
            } else if let userData = userSnapshot?.data(), let user = MWFUser(from: userData) {
                self.user = user
            }
        }
    }

    private func configureView(for user: MWFUser) {
        userView.fullNameLabel.text = user.fullName ?? ""
        if let profileURL = user.profileURL {
            userView.profileImageView.kf.indicatorType = .activity
            userView.profileImageView.kf.setImage(with: URL(string: profileURL))
        } else {
            userView.profileImageView.image = #imageLiteral(resourceName: "user")
        }
    }

}
