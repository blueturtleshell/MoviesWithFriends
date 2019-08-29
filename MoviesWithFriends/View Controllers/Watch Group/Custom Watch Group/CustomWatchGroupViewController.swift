//
//  CustomWatchGroupViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/25/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class CustomWatchGroupViewController: UIViewController {

    let customWatchGroupView: CustomWatchGroupView = {
        return CustomWatchGroupView()
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        return dateFormatter
    }()

    private let mediaManager = MediaManager()
    var watchGroupToEdit: WatchGroup?

    private let db = Firestore.firestore()

    private var friends = [MWFUser]()
    private var invitedFriends = Set<MWFUser>()
    private var maxFriends = 10 {
        didSet {
            updateFriendCountLabel()
        }
    }
    private let MAXFRIENDCAP = 10

    private var state: WatchGroupState = .empty {
        didSet {
            customWatchGroupView.messageLabel.text = state.message

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                guard let self = self else { return }
                self.customWatchGroupView.messageLabel.text = nil
            }
        }
    }
    private var watchDate: Date?

    override func loadView() {
        view = customWatchGroupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureView()
    }

    private func setupView() {
        navigationItem.title = "Custom Watch Group"
        customWatchGroupView.delegate = self
        customWatchGroupView.friendsTableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        customWatchGroupView.friendsTableView.delegate = self
        customWatchGroupView.friendsTableView.dataSource = self
        customWatchGroupView.datePicker.minimumDate = Date()
        customWatchGroupView.datePicker.date = Date()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))

        customWatchGroupView.mediaTitleTextField.delegate = self
        customWatchGroupView.groupNameTextField.delegate = self
        customWatchGroupView.inviteAllButton.addTarget(self, action: #selector(inviteAllButtonPressed), for: .touchUpInside)
        customWatchGroupView.clearSelectionButton.addTarget(self, action: #selector(clearAllButtonPressed), for: .touchUpInside)

        if let _ = watchGroupToEdit {
            navigationItem.rightBarButtonItem?.isEnabled = (invitedFriends.count != 0)
            customWatchGroupView.typeSegmentedControl.isEnabled = false
            customWatchGroupView.mediaTitleTextField.textColor = .lightGray
            customWatchGroupView.mediaTitleTextField.isEnabled = false
            customWatchGroupView.groupNameTextField.textColor = .lightGray
            customWatchGroupView.groupNameTextField.isEnabled = false
            customWatchGroupView.dateButton.setTitleColor(.lightGray, for: .normal)
            customWatchGroupView.dateButton.isEnabled = false
        }
    }

    private func configureView() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        if let watchGroupToEdit = watchGroupToEdit {
            customWatchGroupView.typeSegmentedControl.selectedSegmentIndex = watchGroupToEdit.type == .movie ? 0 : 1
            customWatchGroupView.mediaTitleTextField.text = watchGroupToEdit.mediaTitle
            customWatchGroupView.groupNameTextField.text = watchGroupToEdit.name
            let dateTitle = dateFormatter.string(from: Date(timeIntervalSince1970: watchGroupToEdit.dateInSeconds))
            customWatchGroupView.dateButton.setTitle(dateTitle, for: .normal)
            getUserFriendsAndConfigureForEditing(userID: userID, watchGroupID: watchGroupToEdit.id)
        } else {
            getUserFriends(userID: userID)
        }
    }

    @objc private func inviteAllButtonPressed() {
        invitedFriends = Set(friends)
        updateFriendCountLabel()
        customWatchGroupView.friendsTableView.reloadData()
    }

    @objc private func clearAllButtonPressed() {
        invitedFriends.removeAll()
        updateFriendCountLabel()
        customWatchGroupView.friendsTableView.reloadData()
    }


    @objc private func donePressed() {
        guard invitedFriends.count <= maxFriends else {
            state = .error(message: "Over invited user limit")
            return
        }

        if let watchGroup = watchGroupToEdit {

            guard invitedFriends.count > 0 else {
                state = .error(message: "No changes detected")
                return
            }

            navigationItem.rightBarButtonItem?.isEnabled = false
            inviteNewFriends(to: watchGroup)
        } else {

            guard let userID = Auth.auth().currentUser?.uid else { return }

            guard let mediaTitle = customWatchGroupView.mediaTitleTextField.text, !mediaTitle.isEmpty else {
                state = .error(message: "Title cannot be empty.")
                return
            }

            guard let groupName = customWatchGroupView.groupNameTextField.text, !groupName.isEmpty else {
                state = .error(message: "Group name cannot be empty.")
                return
            }

            guard let watchDate = watchDate else {
                state = .error(message: "Please select a date.")
                return
            }

            if case WatchGroupState.noFriendsSelected = state {
                createWatchGroup(userID: userID, mediaTitle: mediaTitle, groupName:groupName, watchDate: watchDate)
                return
            }

            guard invitedFriends.count > 0  else {
                state = .noFriendsSelected
                return
            }

            navigationItem.rightBarButtonItem?.isEnabled = false
            createWatchGroup(userID: userID, mediaTitle: mediaTitle, groupName:groupName, watchDate: watchDate)
        }
    }

    private func createWatchGroup(userID: String, mediaTitle: String, groupName: String, watchDate: Date) {
        let groupDoc = db.collection("watch_groups").document()
        let id = groupDoc.documentID
        let type = customWatchGroupView.typeSegmentedControl.selectedSegmentIndex == 0 ? "movie" : "tv"
        let userIDs: [String] = invitedFriends.map { $0.id }

        let groupData: [String: Any] = ["id": id, "name": groupName, "type": type,
                                        "media_id": -1, "media_title": mediaTitle,
                                        "poster_path": "", "date": watchDate.timeIntervalSince1970,
                                        "creator_id": userID, "timestamp": Timestamp().seconds]

        let batch = db.batch()
        batch.setData(groupData, forDocument: groupDoc)

        // current user has joined this group
        let currentUserDoc = db.collection("watch_group").document(userID).collection("joined").document(id)
        batch.setData(["id": id], forDocument: currentUserDoc)

        // group adds current user to joined users
        batch.setData(["user_id": userID], forDocument: groupDoc.collection("users_joined").document(userID))


        for userID in userIDs {
            // keep track of users invited
            let watchGroupInvitedUsersDoc = groupDoc.collection("users_invited").document(userID)
            batch.setData(["user_id": userID], forDocument: watchGroupInvitedUsersDoc)

            // invited user has group added to groups invited to
            let doc = db.collection("watch_group").document(userID).collection("invited").document(id)
            batch.setData(["id": id], forDocument: doc)
        }

        batch.commit { error in
            if let error = error {
                self.state = .error(message: error.localizedDescription)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                let watchGroupCreatedHUDView = HUDView.hud(inView: self.view, animated: true)
                watchGroupCreatedHUDView.text = "Group Created"
                watchGroupCreatedHUDView.accessoryType = .image(imageName: "checkmark")

                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

    private func inviteNewFriends(to watchGroup: WatchGroup) {
        let groupDoc = db.collection("watch_groups").document(watchGroup.id)

        let userIDs: [String] = invitedFriends.map { $0.id }

        let batch = db.batch()

        for userID in userIDs {
            // keep track of users invited
            let watchGroupInvitedUsersDoc = groupDoc.collection("users_invited").document(userID)
            batch.setData(["user_id": userID], forDocument: watchGroupInvitedUsersDoc)

            // invited user has group added to groups invited to
            let doc = db.collection("watch_group").document(userID).collection("invited").document(watchGroup.id)
            batch.setData(["id": watchGroup.id], forDocument: doc)
        }

        batch.commit { error in
            if let error = error {
                self.state = .error(message: error.localizedDescription)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                let watchGroupCreatedHUDView = HUDView.hud(inView: self.view, animated: true)
                watchGroupCreatedHUDView.text = "Inviting friends"
                watchGroupCreatedHUDView.accessoryType = .activityIndicator

                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }

    private func getUserFriends(userID: String) {
        db.collection("relationships").document(userID).collection("friends").getDocuments { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let friendIDsSnapshot = snapshot {
                    friendIDsSnapshot.documents.forEach {
                        if let userID = $0.data()["user_id"] as? String {
                            getUser(userID: userID, completion: { user in
                                if let user = user {
                                    self.friends.append(user)
                                    self.friends.sort()
                                    self.customWatchGroupView.friendsTableView.reloadData()
                                    self.updateFriendCountLabel()
                                }
                            })
                        }
                    }
                }
            }
        }
    }

    private func getUserFriendsAndConfigureForEditing(userID: String, watchGroupID: String) {
        // get all user friends
        db.collection("relationships").document(userID).collection("friends").getDocuments { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let friendIDsSnapshot = snapshot {
                    let friendIDs = friendIDsSnapshot.documents.compactMap { return $0.data()["user_id"] as? String }

                    // get all users already in group
                    self.db.collection("watch_groups").document(watchGroupID).collection("users_joined").getDocuments{ snapshot, error in
                        if let error = error {
                            print(error)
                        } else {
                            if let alreadyInGroupSnapshot = snapshot {
                                let userIDsAlreadyInGroup = alreadyInGroupSnapshot.documents.compactMap { return $0.data()["user_id"] as? String }

                                // get all users already invited to group
                                self.db.collection("watch_groups").document(watchGroupID).collection("users_invited").getDocuments{ snapshot, error in
                                    if let error = error {
                                        print(error)
                                    } else {
                                        if let alreadyInvitedSnapshot = snapshot {
                                            let usersAlreadyInvited = alreadyInvitedSnapshot.documents.compactMap { return $0.data()["user_id"] as? String }

                                            var usersIDsValidToInvite = friendIDs.filter { !userIDsAlreadyInGroup.contains($0) }
                                            usersIDsValidToInvite = usersIDsValidToInvite.filter { !usersAlreadyInvited.contains($0) }

                                            self.maxFriends = (self.MAXFRIENDCAP - usersAlreadyInvited.count) - userIDsAlreadyInGroup.count
                                            if self.maxFriends < 0 {
                                                self.maxFriends = 0
                                            }

                                            usersIDsValidToInvite.forEach {
                                                getUser(userID: $0, completion: { user in
                                                    if let user = user {
                                                        self.friends.append(user)
                                                        self.friends.sort()
                                                        self.updateFriendCountLabel()
                                                        self.customWatchGroupView.friendsTableView.reloadData()
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CustomWatchGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]

        //TODO: change colors
        cell.containerView.backgroundColor = invitedFriends.contains(friend) ? UIColor(named: "offGreen") : .white

        cell.userNameLabel.text = friend.userName
        cell.fullNameLabel.text = friend.fullName

        if let profileImagePath = friend.profileURL {
            cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]

        if invitedFriends.contains(friend) {
            invitedFriends.remove(friend)
        } else {
            if invitedFriends.count < maxFriends {
                invitedFriends.insert(friend)
            } else {
                return // cannot invite more friends
            }
        }

        if let _ = watchGroupToEdit {
            navigationItem.rightBarButtonItem?.isEnabled = (invitedFriends.count != 0)
        }

        updateFriendCountLabel()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func updateFriendCountLabel() {
        customWatchGroupView.friendCountLabel.text = "\(invitedFriends.count) / \(maxFriends)"

        if invitedFriends.count == maxFriends {
            customWatchGroupView.friendCountLabel.textColor = .orange
        } else {
            customWatchGroupView.friendCountLabel.textColor = .white
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension CustomWatchGroupViewController: WatchGroupDatePickerToggleDelegate {
    func toggleDatePicker(datePicker: UIDatePicker, isVisible: Bool) {
        watchDate = datePicker.date
        customWatchGroupView.dateButton.setTitle(dateFormatter.string(from: watchDate!), for: .normal)
        customWatchGroupView.dateButton.sizeToFit()
    }
}

extension CustomWatchGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
