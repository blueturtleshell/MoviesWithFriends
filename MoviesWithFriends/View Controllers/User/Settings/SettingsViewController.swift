//
//  SettingsViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/27/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {

    let settingsView: SettingsView = {
        return SettingsView()
    }()

    private let user: MWFUser
    private let db = Firestore.firestore()

    private var isBookmarkPublic = false {
        didSet {
            settingsView.bookmarkSwitch.isOn = isBookmarkPublic
        }
    }
    private var isFriendsPublic = false {
        didSet {
            settingsView.friendsSwitch.isOn = isFriendsPublic
        }
    }

    private var changesMade = false

    init(user: MWFUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if changesMade {
            let userSettingsData: [String: Bool] = ["bookmark_public": isBookmarkPublic,
                                                  "friends_public": isFriendsPublic]

            db.collection("user_settings").document(user.id).setData(userSettingsData) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    private func setupView() {
        navigationItem.title = "Settings"
        settingsView.changeRegionButton.addTarget(self, action: #selector(showChangeRegion), for: .touchUpInside)
        settingsView.bookmarkSwitch.addTarget(self, action: #selector(bookmarksPublicSwitchChanged), for: .valueChanged)
        settingsView.friendsSwitch.addTarget(self, action: #selector(friendsPublicSwitchChanged), for: .valueChanged)
    }

    private func configureView() {
        settingsView.currentRegionLabel.text = "USA"

        db.collection("user_settings").document(user.id).getDocument { settingsDoc, error in
            if let error = error {
                print(error)
            } else {
                if let settingsDoc = settingsDoc {
                    self.isBookmarkPublic = settingsDoc.data()?["bookmark_public"] as? Bool ?? false
                    self.isFriendsPublic = settingsDoc.data()?["friends_public"] as? Bool ?? false
                }
            }
        }
    }

    @objc private func showChangeRegion() {
        let regionViewController = RegionViewController()
        navigationController?.pushViewController(regionViewController, animated: true)
    }

    @objc private func bookmarksPublicSwitchChanged(_ sender: UISwitch) {
        changesMade = true
        isBookmarkPublic = sender.isOn
    }

    @objc private func friendsPublicSwitchChanged(_ sender: UISwitch) {
        changesMade = true
        isFriendsPublic = sender.isOn
    }
}
