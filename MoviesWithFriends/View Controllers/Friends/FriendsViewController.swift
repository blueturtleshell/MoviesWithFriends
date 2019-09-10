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
    private var friendSnapshotListener: ListenerRegistration?
    private var pendingFriendSnapshotListener: ListenerRegistration?

    private var user: MWFUser

    private var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == user.id
    }

    fileprivate var relationshipState: RelationshipState = .sendRequest
    private var friends = [(user: MWFUser, state: RelationshipState)]()
    private var pendingFriends = [MWFUser]()

    init(user: MWFUser, mediaManager: MediaManager) {
        self.user = user
        self.mediaManager = mediaManager
        super.init(style: .plain)
        tabBarItem = UITabBarItem(title: "Friends", image: UIImage(named: "user"), tag: 2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchFriends()
    }

    private func setupView() {
        if isCurrentUser {
            navigationItem.title = "Your friends"
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFriend))
        } else {
            navigationItem.title = "\(user.fullName ?? user.userName) friends"
        }

        navigationItem.backBarButtonItem = UIBarButtonItem()

        if isCurrentUser {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "qr"), style: .plain, target: self, action: #selector(displayFriendCode))
        }

        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        tableView.register(FriendPendingCell.self, forCellReuseIdentifier: "PendingCell")
        tableView.register(FriendRequestCell.self, forCellReuseIdentifier: "RequestCell")
        tableView.register(FetchingTBCell.self, forCellReuseIdentifier: "FetchingCell")

        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpFirestoreListeners), name: .userDidLogout, object: nil)
    }

    @objc private func cleanUpFirestoreListeners(_ notification: Notification) {
        friendSnapshotListener?.remove()
        pendingFriendSnapshotListener?.remove()
    }

    @objc private func displayFriendCode() {
        let friendCodeViewController = FriendCodeViewController(user: user)
        navigationController?.pushViewController(friendCodeViewController, animated: true)
    }

    @objc private func addFriend() {
        let friendViewController = FriendViewController(user: user)
        navigationController?.pushViewController(friendViewController, animated: true)
    }

    private func fetchFriends() {
        let fetchingHUD = HUDView.hud(inView: tableView, animated: true)
        view.bringSubviewToFront(fetchingHUD)
        fetchingHUD.text = "Fetching friends"
        fetchingHUD.accessoryType = .activityIndicator

        friendSnapshotListener = db.collection("relationships").document(user.id).collection("friends").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {

                    fetchingHUD.remove(from: self.view)

                    if snapshot.documents.isEmpty {
                        self.tableView.reloadData()
                        return
                    }

                    snapshot.documentChanges.forEach { diff in
                        guard let userID = diff.document.data()["user_id"] as? String else { return }
                        getUser(userID: userID, completion: { user in
                            guard let user = user else { return }

                            switch diff.type {
                            case .added:
                                if self.isCurrentUser { // you are the user, add all your friends to the list
                                    self.friends.append((user: user, state: .alreadyFriends))
                                } else {
                                    guard let currentUserID = Auth.auth().currentUser?.uid else { return }

                                    if currentUserID == user.id {
                                        self.friends.append((user: user, state: .currentUser))
                                    } else {
                                        // need to check if already friends
                                        self.checkifFriends(currentUserID: currentUserID, otherUser: user, completion: { isFriends in
                                            if isFriends {
                                                self.friends.append((user: user, state: .alreadyFriends))
                                                self.friends.sort(by: { $0.user < $1.user })
                                                self.tableView.reloadData()
                                            } else {
                                                // check if request already sent
                                                self.checkIfUserIsPending(currentUserID: currentUserID, otherUser: user, completion: { isPending in
                                                    if isPending {
                                                        self.friends.append((user: user, state: .requestSent))
                                                    } else {
                                                        self.friends.append((user: user, state: .sendRequest))
                                                    }

                                                    self.friends.sort(by: { $0.user < $1.user })
                                                    self.tableView.reloadData()
                                                })
                                            }
                                        })
                                    }
                                }

                                self.friends.sort(by: { $0.user < $1.user })
                                self.tableView.reloadData()
                            case .removed:
                                if let index = self.friends.firstIndex(where: {
                                    $0.user == user
                                }) {
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

        // only current user can see users requesting to be friends
        if isCurrentUser {
            // users that have requested to be friends, pending approval
            pendingFriendSnapshotListener = db.collection("relationships").document(user.id).collection("requests").addSnapshotListener { snapshot, error in
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
                                    self.pendingFriends.append(requestedUser)
                                    self.pendingFriends.sort(by: <)
                                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .right)
                                case .removed:
                                    if let index = self.pendingFriends.firstIndex(of: requestedUser) {
                                        self.pendingFriends.remove(at: index)
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
    }

    private func checkifFriends(currentUserID: String, otherUser: MWFUser, completion: @escaping (Bool) -> Void) {
        db.collection("relationships").document(currentUserID).collection("friends").document(otherUser.id).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                completion(userSnapshot?.exists ?? false)
            }
        }
    }

    private func checkIfUserIsPending(currentUserID: String, otherUser: MWFUser, completion: @escaping (Bool) -> Void) {
        db.collection("relationships").document(currentUserID).collection("pending").document(otherUser.id).getDocument { snapshot, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                completion(snapshot?.exists ?? false)
            }
        }
    }

    private func configure(cell: FriendRequestCell, state: RelationshipState) {
        switch state {
        case .sendRequest, .alreadyFriends:
            cell.actionButton.isEnabled = true
            cell.actionButton.isHidden = false
        case .requestSent:
            cell.actionButton.isEnabled = false
            cell.actionButton.isHidden = false
        case .currentUser:
            cell.actionButton.isEnabled = false
            cell.actionButton.isHidden = true
        default:
            cell.actionButton.isEnabled = true
            cell.actionButton.isHidden = false
        }
        cell.actionButton.setTitle(state.rawValue, for: .normal)
    }

    // MARK: - tableview

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isCurrentUser {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if friends.isEmpty && pendingFriends.isEmpty {
            let backgroundView = BackgroundLabelView()
            backgroundView.textLabel.text = "No friends found"
            tableView.backgroundView = backgroundView
            return 0
        }

        tableView.backgroundView = nil

        if section == 0 {
            return friends.count
        } else {
            return pendingFriends.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if isCurrentUser {
                let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
                let friend = friends[indexPath.row].user

                cell.userNameLabel.text = friend.userName
                cell.fullNameLabel.text = friend.fullName

                if let profileImagePath = friend.profileURL {
                    cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
                }

                return cell
            } else {
                // you are looking at friend friends, able to request to be friends
                let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! FriendRequestCell
                cell.delegate = self
                let requestedUser = friends[indexPath.row].user

                cell.userNameLabel.text = requestedUser.userName
                cell.fullNameLabel.text = requestedUser.fullName

                if let profileImagePath = requestedUser.profileURL {
                    cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
                }

                configure(cell: cell, state: friends[indexPath.row].state)

                return cell
            }

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingCell", for: indexPath) as! FriendPendingCell
            cell.delegate = self
            let requestedUser = pendingFriends[indexPath.row]

            cell.userNameLabel.text = requestedUser.userName
            cell.fullNameLabel.text = requestedUser.fullName

            if let profileImagePath = requestedUser.profileURL {
                cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if isCurrentUser {
                return 80
            } else {
                return 125
            }
        } else {
            return 125
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row].user

        let userViewController = UserViewController(user: friend, mediaManager: mediaManager)
        navigationController?.pushViewController(userViewController, animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            if pendingFriends.isEmpty {
                return 0
            } else {
                return 52
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 && !pendingFriends.isEmpty {
            let inviteHeader = InviteHeaderView()
            inviteHeader.headerTitleLabel.text = "Requests"
            return inviteHeader
        }
        return nil
    }
}

extension FriendsViewController: FriendPendingCellDelegate {
    func acceptPressed(_ cell: FriendPendingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let friend = pendingFriends[indexPath.row]

        let batch = db.batch()
        // current user remove requested friend id from request collection
        let currentUserRequestDoc = db.collection("relationships").document(user.id).collection("requests").document(friend.id)
        batch.deleteDocument(currentUserRequestDoc)

        // friend remove current user id from pending collection
        let requestedFriendDoc = db.collection("relationships").document(friend.id).collection("pending").document(user.id)
        batch.deleteDocument(requestedFriendDoc)

        //currentUser add requested friend id to friends collection
        let currentUserFriendDoc = db.collection("relationships").document(user.id).collection("friends").document(friend.id)
        batch.setData(["user_id": friend.id], forDocument: currentUserFriendDoc)
        //friend add current user id to friends collection
        let friendDoc = db.collection("relationships").document(friend.id).collection("friends").document(user.id)
        batch.setData(["user_id": user.id], forDocument: friendDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }

    func denyPressed(_ cell: FriendPendingCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let requestedUser = pendingFriends[indexPath.row]

        let batch = db.batch()
        // current user add remove requested user from pending collection
        let currentUserRequestDoc = db.collection("relationships").document(user.id).collection("requests").document(requestedUser.id)
        batch.deleteDocument(currentUserRequestDoc)

        // request user remove current user id from request collection
        let requestedUserDoc = db.collection("relationships").document(requestedUser.id).collection("pending").document(user.id)
        batch.deleteDocument(requestedUserDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }
}

extension FriendsViewController: FriendRequestCellDelegate {
    func requestSent(_ cell: FriendRequestCell) {
        guard let indexPath = tableView.indexPath(for: cell),
            let currentUserID = Auth.auth().currentUser?.uid else { return }
        let friend = friends[indexPath.row].user
        friends[indexPath.row].state = .requestSent

        let batch = db.batch()

        // current user add requested user to pending collection
        let currentUserRequestDoc = db.collection("relationships").document(currentUserID).collection("pending").document(friend.id)
        batch.setData(["user_id": friend.id], forDocument: currentUserRequestDoc)

        // request user add current user id to request collection
        let requestedUserDoc = db.collection("relationships").document(friend.id).collection("requests").document(currentUserID)
        batch.setData(["user_id": currentUserID], forDocument: requestedUserDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            } else {
                self.tableView.reloadRows(at: [IndexPath(item: indexPath.row, section: 0)], with: .automatic)
            }
        }
    }
}
