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
    private var isWatchGroupsPublic = false {
        didSet {
            settingsView.watchGroupsSwitch.isOn = isWatchGroupsPublic
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
                                                  "friends_public": isFriendsPublic,
                                                  "watch_groups_public": isWatchGroupsPublic]

            db.collection("user_settings").document(user.id).setData(userSettingsData) { error in
                if let error = error {
                    print(error)
                }
            }
        }
    }

    private func setupView() {
        navigationItem.title = "Settings"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(handleLogout))

        settingsView.changeCountryButton.addTarget(self, action: #selector(showChangeCountry), for: .touchUpInside)
        settingsView.bookmarkSwitch.addTarget(self, action: #selector(bookmarksPublicSwitchChanged), for: .valueChanged)
        settingsView.friendsSwitch.addTarget(self, action: #selector(friendsPublicSwitchChanged), for: .valueChanged)
        settingsView.watchGroupsSwitch.addTarget(self, action: #selector(watchGroupsPublicSwitchChanged), for: .valueChanged)
    }

    private func configureView() {

        settingsView.currentCountryLabel.text = UserDefaults.standard.string(forKey: "countryName") ?? "United States of America"

        db.collection("user_settings").document(user.id).getDocument { settingsDoc, error in
            if let error = error {
                print(error)
            } else {
                if let settingsDoc = settingsDoc {
                    self.isBookmarkPublic = settingsDoc.data()?["bookmark_public"] as? Bool ?? false
                    self.isFriendsPublic = settingsDoc.data()?["friends_public"] as? Bool ?? false
                    self.isWatchGroupsPublic = settingsDoc.data()?["watch_groups_public"] as? Bool ?? false
                }
            }
        }
    }

    @objc private func handleLogout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure?", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive, handler: logoutUser)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc private func logoutUser(_ alertAction: UIAlertAction) {
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }

    @objc private func showChangeCountry() {
        let countryViewController = CountryViewController()
        countryViewController.delegate = self
        navigationController?.pushViewController(countryViewController, animated: true)
    }

    @objc private func bookmarksPublicSwitchChanged(_ sender: UISwitch) {
        changesMade = true
        isBookmarkPublic = sender.isOn
    }

    @objc private func friendsPublicSwitchChanged(_ sender: UISwitch) {
        changesMade = true
        isFriendsPublic = sender.isOn
    }

    @objc private func watchGroupsPublicSwitchChanged(_ sender: UISwitch) {
        changesMade = true
        isWatchGroupsPublic = sender.isOn
    }
}

extension SettingsViewController: CountryViewControllerDelegate {
    func didSelectNewCountry(viewController: CountryViewController, country: Country) {
        let countryValues: [String: String] = ["countryCode": country.name, "countryCode": country.countryCode]
        UserDefaults.standard.setValuesForKeys(countryValues)

        settingsView.currentCountryLabel.text = country.name

        navigationController?.popViewController(animated: true)
    }
}
