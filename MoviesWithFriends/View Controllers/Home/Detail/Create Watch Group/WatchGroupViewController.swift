//
//  WatchGroupViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/25/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class WatchGroupViewController: UIViewController {

    private let watchGroupView: WatchGroupView = {
        return WatchGroupView()
    }()

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        return dateFormatter
    }()

    private let mediaType: MediaType
    private let mediaInfo: MediaInfo
    private let mediaManager: MediaManager
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
            watchGroupView.messageLabel.text = state.message

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                guard let self = self else { return }
                self.watchGroupView.messageLabel.text = nil
            }
        }
    }
    private var watchDate: Date?

    init(mediaType: MediaType, mediaInfo: MediaInfo, mediaManager: MediaManager) {
        self.mediaType = mediaType
        self.mediaInfo = mediaInfo
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = watchGroupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        configureView()
    }

    private func setupView() {
        navigationItem.title = watchGroupToEdit == nil ? "Create Watch Group" : "Edit Watch Group"
        watchGroupView.delegate = self
        watchGroupView.friendsTableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
        watchGroupView.friendsTableView.delegate = self
        watchGroupView.friendsTableView.dataSource = self
        watchGroupView.datePicker.minimumDate = calculateMinimumDate()
        watchGroupView.datePicker.date = calculateMinimumDate()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))

        watchGroupView.groupNameTextField.delegate = self
        watchGroupView.inviteAllButton.addTarget(self, action: #selector(inviteAllButtonPressed), for: .touchUpInside)
        watchGroupView.clearSelectionButton.addTarget(self, action: #selector(clearAllButtonPressed), for: .touchUpInside)

        if let _ = watchGroupToEdit {
            navigationItem.rightBarButtonItem?.isEnabled = (invitedFriends.count != 0)
            watchGroupView.groupNameTextField.textColor = .lightGray
            watchGroupView.groupNameTextField.isEnabled = false
            watchGroupView.dateButton.setTitleColor(.lightGray, for: .normal)
            watchGroupView.dateButton.isEnabled = false
        }
    }

    private func configureView() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        watchGroupView.mediaTitleLabel.text = mediaInfo.title

        if let posterPath = mediaInfo.posterPath {
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            watchGroupView.posterImageView.kf.setImage(with: imageURL)
        }

        if let watchGroupToEdit = watchGroupToEdit {
            watchGroupView.groupNameTextField.text = watchGroupToEdit.name
            let dateTitle = dateFormatter.string(from: Date(timeIntervalSince1970: watchGroupToEdit.dateInSeconds))
            watchGroupView.dateButton.setTitle(dateTitle, for: .normal)
            getUserFriendsAndConfigureForEditing(userID: userID, watchGroupID: watchGroupToEdit.id)
        } else {
            getUserFriends(userID: userID)
        }
    }

    @objc private func inviteAllButtonPressed() {
        invitedFriends = Set(friends)
        updateFriendCountLabel()
        watchGroupView.friendsTableView.reloadData()
    }

    @objc private func clearAllButtonPressed() {
        invitedFriends.removeAll()
        updateFriendCountLabel()
        watchGroupView.friendsTableView.reloadData()
    }

    @objc private func donePressed() {
        guard invitedFriends.count <= maxFriends else {
            state = .error(message: "Over invited user limit")
            return
        }

        if let watchGroup = watchGroupToEdit {

            guard invitedFriends.count > 0  else {
                state = .error(message: "No changes detected")
                return
            }

            navigationItem.rightBarButtonItem?.isEnabled = false
            inviteNewFriends(to: watchGroup)
        } else {

            guard let userID = Auth.auth().currentUser?.uid else { return }

            guard let groupName = watchGroupView.groupNameTextField.text, !groupName.isEmpty else {
                state = .error(message: "Group name cannot be empty.")
                return
            }

            guard let watchDate = watchDate else {
                state = .error(message: "Please select a date to watch \(mediaInfo.title)")
                return
            }

            if case WatchGroupState.noFriendsSelected = state {
                createWatchGroup(userID: userID, groupName:groupName, watchDate: watchDate)
                return
            }

            guard invitedFriends.count > 0  else {
                state = .noFriendsSelected
                return
            }

            navigationItem.rightBarButtonItem?.isEnabled = false
            createWatchGroup(userID: userID, groupName:groupName, watchDate: watchDate)
        }
    }

    private func calculateMinimumDate() -> Date {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        if let releaseDate = mediaInfo.releaseDate, let date = dateFormatter.date(from: releaseDate) {
            return date > today ? date : today
        } else {
            return today
        }
    }

    private func createWatchGroup(userID: String, groupName: String, watchDate: Date) {
        let groupDoc = db.collection("watch_groups").document()
        let id = groupDoc.documentID
        let type = mediaType == .movie ? "movie" : "tv"
        let userIDs: [String] = invitedFriends.map { $0.id }

        let groupData: [String: Any] = ["id": id, "name": groupName, "type": type,
                                        "media_id": mediaInfo.id, "media_title": mediaInfo.title,
                                        "poster_path": mediaInfo.posterPath ?? "", "date": watchDate.timeIntervalSince1970,
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
                                    self.watchGroupView.friendsTableView.reloadData()
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

                                            // subtract users already in group and users invited
                                            self.maxFriends = (self.MAXFRIENDCAP - usersAlreadyInvited.count) - userIDsAlreadyInGroup.count
                                            if self.maxFriends < 0 {
                                                self.maxFriends = 0
                                            }

                                            usersIDsValidToInvite.forEach {
                                                getUser(userID: $0, completion: { user in
                                                    if let user = user {
                                                        self.friends.append(user)
                                                        self.friends.sort()
                                                        self.watchGroupView.friendsTableView.reloadData()
                                                        self.updateFriendCountLabel()
                                                        self.watchGroupView.friendsTableView.reloadData()
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

extension WatchGroupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = friends[indexPath.row]

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
            // button disabled at start for editing, if change detected enable done button
            navigationItem.rightBarButtonItem?.isEnabled = (invitedFriends.count != 0)
        }

        updateFriendCountLabel()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    private func updateFriendCountLabel() {
        watchGroupView.friendCountLabel.text = "\(invitedFriends.count) / \(maxFriends)"

        if invitedFriends.count == maxFriends {
            watchGroupView.friendCountLabel.textColor = .orange
        } else {
            watchGroupView.friendCountLabel.textColor = .white
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}

extension WatchGroupViewController: WatchGroupDatePickerToggleDelegate {

    func toggleDatePicker(datePicker: UIDatePicker, isVisible: Bool) {
        watchDate = datePicker.date
        watchGroupView.dateButton.setTitle(dateFormatter.string(from: watchDate!), for: .normal)
        watchGroupView.dateButton.sizeToFit()
    }
}

extension WatchGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
