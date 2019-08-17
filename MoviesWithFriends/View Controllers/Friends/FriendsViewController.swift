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

    private var currentUser: MWFUser? {
        didSet {
            navigationItem.leftBarButtonItem?.isEnabled = currentUser != nil
        }
    }
    private var friends = [MWFUser]()
    private var requestedFriends = [MWFUser]()
    private var isFetching = false

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(style: .plain)
        tabBarItem = UITabBarItem(title: "Friends", image: UIImage(named: "user"), tag: 2)
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
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Friend", style: .plain, target: self, action: #selector(displayFriendCode))
        navigationItem.leftBarButtonItem?.isEnabled = false

        tableView.tableFooterView = UIView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
        tableView.register(RequestCell.self, forCellReuseIdentifier: "RequestCell")
        tableView.register(FetchingCell.self, forCellReuseIdentifier: "FetchingCell")
    }

    @objc private func displayFriendCode() {
        guard let currentUser = currentUser else { return }
        let friendCodeViewController = FriendCodeViewController(user: currentUser)
        navigationController?.pushViewController(friendCodeViewController, animated: true)
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
        navigationController?.pushViewController(friendViewController, animated: true)
    }

    private func fetchFriends() {
        isFetching = true
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("relationships").document(userID).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    if snapshot.documents.count == 0 {
                        self.isFetching = false
                        self.tableView.reloadData()
                        return
                    }

                    snapshot.documentChanges.forEach { diff in
                        guard let userID = diff.document.data()["user_id"] as? String else { return }
                        getUser(userID: userID, completion: { requestedUser in
                            guard let requestedUser = requestedUser else { return }

                            switch diff.type {
                            case .added:
                                self.isFetching = false
                                self.friends.append(requestedUser)
                                self.friends.sort()
                                self.tableView.reloadData()
                            case .removed:
                                if let index = self.friends.firstIndex(of: requestedUser) {
                                    self.friends.remove(at: index)
                                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                                }
                            default:
                                print("Modified not used")
                            }
                        })
                    }
                }
            }
        }

        db.collection("relationships").document(userID).collection("requests").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let userID = diff.document.data()["user_id"] as? String else { return }
                        getUser(userID: userID, completion: { requestedUser in
                            guard let requestedUser = requestedUser else { return }

                            switch diff.type {
                            case .added:
                                self.requestedFriends.append(requestedUser)
                                self.requestedFriends.sort(by: <)
                                self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .right)
                            case .removed:
                                if let index = self.requestedFriends.firstIndex(of: requestedUser) {
                                    self.requestedFriends.remove(at: index)
                                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .right)
                                }
                            default:
                                print("Modified not used")
                            }
                        })
                    }
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
        return requestedFriends.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if friends.isEmpty {
                if isFetching {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FetchingCell", for: indexPath) as! FetchingCell
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                    cell.emptyTextLabel.text = "No Friends\nPress + to begin"
                    return cell
                }
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
            let friend = friends[indexPath.row]

            cell.userNameLabel.text = friend.userName
            cell.fullNameLabel.text = friend.fullName

            if let profileImagePath = friend.profileURL {
                cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
            }

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
            cell.delegate = self
            let requestedUser = requestedFriends[indexPath.row]

            cell.userNameLabel.text = requestedUser.userName
            cell.fullNameLabel.text = requestedUser.fullName

            if let profileImagePath = requestedUser.profileURL {
                cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if friends.isEmpty {
            return isFetching ? 60 : 250
        }

        if indexPath.section == 0 {
            return 60
        } else {
            return 125
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Requests"
        }
        return nil
    }
}

extension FriendsViewController: RequestCellDelegate {
    func acceptPressed(_ cell: RequestCell) {
        guard let currentUser = currentUser, let indexPath = tableView.indexPath(for: cell) else { return }
        let friend = requestedFriends[indexPath.row]

        let batch = db.batch()
        // current user add remove requested friend from request collection
        let currentUserRequestDoc = db.collection("relationships").document(currentUser.id).collection("requests").document(friend.id)
        batch.deleteDocument(currentUserRequestDoc)

        // friend remove current user id from pending collection
        let requestedFriendDoc = db.collection("relationships").document(friend.id).collection("pending").document(currentUser.id)
        batch.deleteDocument(requestedFriendDoc)

        //currentUser add requested friend id to friends collection
        let currentUserFriendDoc = db.collection("relationships").document(currentUser.id).collection("friends").document(friend.id)
        batch.setData(["user_id": friend.id], forDocument: currentUserFriendDoc)
        //friend add current user id to friends collection
        let friendDoc = db.collection("relationships").document(friend.id).collection("friends").document(currentUser.id)
        batch.setData(["user_id": currentUser.id], forDocument: friendDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }

    func denyPressed(_ cell: RequestCell) {
        guard let currentUser = currentUser, let indexPath = tableView.indexPath(for: cell) else { return }
        let requestedUser = requestedFriends[indexPath.row]

        let batch = db.batch()
        // current user add remove requested user from pending collection
        let currentUserRequestDoc = db.collection("relationships").document(currentUser.id).collection("requests").document(requestedUser.id)
        batch.deleteDocument(currentUserRequestDoc)

        // request user remove current user id from request collection
        let requestedUserDoc = db.collection("relationships").document(requestedUser.id).collection("pending").document(currentUser.id)
        batch.deleteDocument(requestedUserDoc)


        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }
}
