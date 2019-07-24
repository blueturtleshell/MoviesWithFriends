//
//  FriendsViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/19/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: UITableViewController {

    private let mediaManager: MediaManager

    private var db = Firestore.firestore()

    private var currentUser: MWFUser?
    private var friends = [MWFUser]()
    private var pendingFriends = [MWFUser]()

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(style: .plain)
        tabBarItem = UITabBarItem(title: "Friends", image: UIImage(named: "user"), tag: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))

        setupView()

        fetchCurrentUser()
        fetchFriends()
    }

    private func setupView() {
        navigationItem.title = "Friends"
        tableView.tableFooterView = UIView()
        tableView.register(CreditCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
    }

    private func fetchCurrentUser() {
        navigationItem.rightBarButtonItem?.isEnabled = false
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(currentUserID).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
            } else if let snapshot = userSnapshot, let userData = snapshot.data(),
                let user = MWFUser(from: userData) {
                self.currentUser = user
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }

    @objc private func addFriend() {
        guard let currentUser = currentUser else { return }
        let friendViewController = FriendViewController(user: currentUser)
        friendViewController.modalPresentationStyle = .overFullScreen
        present(friendViewController, animated: true, completion: nil)
    }

    private func fetchFriends() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("friends").document(userID).collection("active").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let friends = snapshot?.documents.compactMap({ MWFUser(from: $0.data()) }) {
                    self.friends = friends
                    self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
                }
            }
        }

        db.collection("friends").document(userID).collection("requests").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let friends = snapshot?.documents.compactMap({ MWFUser(from: $0.data()) }) {
                    self.pendingFriends = friends
                    self.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if friends.isEmpty {
                return 1
            }
            return friends.count
        }
        return pendingFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if friends.isEmpty {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                cell.emptyTextLabel.text = "No Friends :("
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! CreditCell
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! CreditCell
            return cell
        }
    }

    
}
