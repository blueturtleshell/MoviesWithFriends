//
//  UserOptionsViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/14/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class WatchGroupOptionsViewController: UITableViewController {

    private let mediaManager: MediaManager

    private let watchGroup: WatchGroup

    private let db = Firestore.firestore()
    private var usersInGroup = [MWFUser]()

    init(watchGroup: WatchGroup, mediaManager: MediaManager) {
        self.watchGroup = watchGroup
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        fetchUsers()
    }

    private func setupView() {
        navigationItem.title = "Users in watch group"
        if let currentUserID = Auth.auth().currentUser?.uid {
            if watchGroup.creatorID == currentUserID {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editGroup))
            }
        }

        tableView.register(FetchingTBCell.self, forCellReuseIdentifier: "FetchingCell")
        tableView.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")

        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
    }

    @objc private func editGroup() {
        if watchGroup.mediaID < 0 {
            let customWatchGroupDetailViewController = CustomWatchGroupViewController(mediaManager: mediaManager)
            customWatchGroupDetailViewController.watchGroupToEdit = watchGroup
            navigationController?.pushViewController(customWatchGroupDetailViewController, animated: true)
        } else {
            switch watchGroup.type {
            case .movie:
                mediaManager.fetchMovieDetail(id: watchGroup.mediaID) { detailResult in
                    do {
                        let mediaInfo = try detailResult.get()
                        let watchGroupViewController = WatchGroupViewController(mediaType: self.watchGroup.type,
                                                                                mediaInfo: mediaInfo, mediaManager: self.mediaManager)
                        watchGroupViewController.watchGroupToEdit = self.watchGroup
                        self.navigationController?.pushViewController(watchGroupViewController, animated: true)
                    } catch {
                        print(error)
                    }
                }
            case .tv:
                mediaManager.fetchTVShowDetail(id: watchGroup.mediaID) { detailResult in
                    do {
                        let mediaInfo = try detailResult.get()
                        let watchGroupViewController = WatchGroupViewController(mediaType: self.watchGroup.type,
                                                                                mediaInfo: mediaInfo, mediaManager: self.mediaManager)
                        watchGroupViewController.watchGroupToEdit = self.watchGroup
                        self.navigationController?.pushViewController(watchGroupViewController, animated: true)
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }

    private func fetchUsers() {
        let fetchingUsersHUD = HUDView.hud(inView: view, animated: true)
        fetchingUsersHUD.text = "Fetching users"
        fetchingUsersHUD.accessoryType = .activityIndicator

        db.collection("watch_groups").document(watchGroup.id).collection("users_joined").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {

                    fetchingUsersHUD.remove(from: self.view)

                    if snapshot.documents.count == 0 {
                        self.tableView.reloadData()
                        return
                    }

                    snapshot.documentChanges.forEach { diff in
                        guard let userID = diff.document.data()["user_id"] as? String else { return }
                        getUser(userID: userID, completion: { user in
                            guard let user = user else { return }

                            switch diff.type {
                            case .added:
                                self.usersInGroup.append(user)

                                if self.usersInGroup.count == 1 {
                                    self.tableView.reloadData()
                                } else {
                                    self.tableView.insertRows(at: [IndexPath(row: self.usersInGroup.count - 1, section: 0)], with: .automatic)
                                }
                            case .modified:
                                if let index = self.usersInGroup.firstIndex(of: user) {
                                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                                }
                            case .removed:
                                if let index = self.usersInGroup.firstIndex(of: user) {
                                    self.usersInGroup.remove(at: index)
                                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                                }
                            default:
                                print("TBA")
                            }
                        })
                    }
                }
            }
        }
    }

    // MARK: - Tableview

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersInGroup.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        let friend = usersInGroup[indexPath.row]

        cell.userNameLabel.text = friend.userName
        cell.fullNameLabel.text = friend.fullName

        if let profileImagePath = friend.profileURL {
            cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}
