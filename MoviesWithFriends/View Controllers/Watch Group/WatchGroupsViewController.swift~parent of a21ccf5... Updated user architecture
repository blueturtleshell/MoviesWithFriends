//
//  WatchGroupsViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class WatchGroupsViewController: UIViewController {

    let watchGroupsView: WatchGroupsView = {
        return WatchGroupsView()
    }()

    private let mediaManager: MediaManager

    private var db = Firestore.firestore()

    private var joinedWatchGroups = [WatchGroup]()
    private var pendingWatchGroups = [WatchGroup]()
    private var isFetching = false

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Watch Groups", image: UIImage(named: "user"), tag: 2)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = watchGroupsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()

        fetchWatchGroups()
    }

    private func setupView() {
        navigationItem.title = "Watch Groups"
        navigationItem.backBarButtonItem = UIBarButtonItem()
        watchGroupsView.tableView.dataSource = self
        watchGroupsView.tableView.delegate = self
        watchGroupsView.tableView.tableFooterView = UIView()
        watchGroupsView.tableView.register(WatchGroupCell.self, forCellReuseIdentifier: "WatchGroupCell")
        watchGroupsView.tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
        watchGroupsView.tableView.register(RequestCell.self, forCellReuseIdentifier: "RequestCell")
        watchGroupsView.tableView.register(FetchingCell.self, forCellReuseIdentifier: "FetchingCell")
    }

    private func fetchWatchGroups() {
        isFetching = true
        guard let userID = Auth.auth().currentUser?.uid else { return }

        db.collection("watch_group").document(userID).collection("joined").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    if snapshot.documents.count == 0 {
                        self.isFetching = false
                        self.watchGroupsView.tableView.reloadData()
                        return
                    }

                    snapshot.documentChanges.forEach { diff in
                        guard let groupID = diff.document.data()["id"] as? String else { return }
                        getWatchGroup(groupID: groupID) { watchGroup in
                            guard let watchGroup = watchGroup else { return }

                            switch diff.type {
                            case .added:
                                let lastIndex = self.joinedWatchGroups.count
                                self.joinedWatchGroups.append(watchGroup)
                                if self.joinedWatchGroups.count == 1 {
                                    self.isFetching = false
                                    self.watchGroupsView.tableView.reloadData()
                                } else {
                                    self.watchGroupsView.tableView.insertRows(at: [IndexPath(row: lastIndex, section: 0)], with: .automatic)
                                }
                            case .removed:
                                if let index = self.joinedWatchGroups.firstIndex(of: watchGroup) {
                                    self.joinedWatchGroups.remove(at: index)
                                    self.watchGroupsView.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                                }
                            default:
                                print("Modified not used")
                            }
                        }
                    }
                }
            }
        }

        db.collection("watch_group").document(userID).collection("invited").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let groupID = diff.document.data()["id"] as? String else { return }
                        getWatchGroup(groupID: groupID) { watchGroup in
                            guard let watchGroup = watchGroup else { return }

                            switch diff.type {
                            case .added:
                                self.pendingWatchGroups.append(watchGroup)
                                self.watchGroupsView.tableView.reloadData()
                                self.isFetching = false
                            case .removed:
                                if let index = self.pendingWatchGroups.firstIndex(of: watchGroup) {
                                    self.pendingWatchGroups.remove(at: index)
                                    self.watchGroupsView.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .right)
                                }
                            default:
                                print("Modified not used")
                            }
                        }
                    }
                }
            }
        }
    }
}

extension WatchGroupsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if joinedWatchGroups.isEmpty {
                return 1
            }
            return joinedWatchGroups.count
        }
        return pendingWatchGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if joinedWatchGroups.isEmpty {
                if isFetching {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "FetchingCell", for: indexPath) as! FetchingCell
                    cell.fetchLabel.text = "Fetching Groups"
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                    cell.emptyTextLabel.text = "No watch groups scheduled"
                    return cell
                }
            }

            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchGroupCell", for: indexPath) as! WatchGroupCell
            let group = joinedWatchGroups[indexPath.row]

            cell.groupID = group.id

            cell.groupNameLabel.text = group.name
            cell.movieNameLabel.text = group.mediaTitle
            cell.dateLabel.text = group.displayDate

            if let posterImagePath = group.posterPath {
                let posterURL = mediaManager.getImageURL(for: .poster(path: posterImagePath, size: .medium))
                cell.posterImageView.kf.setImage(with: posterURL)
            }

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath) as! RequestCell
            cell.delegate = self
            let pendingGroup = pendingWatchGroups[indexPath.row]

            cell.userNameLabel.text = pendingGroup.name
            cell.fullNameLabel.text = pendingGroup.mediaTitle

            if let posterImagePath = pendingGroup.posterPath {
                let posterURL = mediaManager.getImageURL(for: .poster(path: posterImagePath, size: .medium))
                cell.profileImageView.kf.setImage(with: posterURL)
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 && !isFetching else { return }

        let groupDetailViewController = WatchGroupDetailViewController(watchGroup: joinedWatchGroups[indexPath.row])
        //groupDetailViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupDetailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if joinedWatchGroups.isEmpty {
                return isFetching ? 80 : 250
            }
            return 154
        } else {
            return 125
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return pendingWatchGroups.count > 0 ? "Invited" : nil
        }
        return nil
    }
}

extension WatchGroupsViewController: RequestCellDelegate {
    func acceptPressed(_ cell: RequestCell) {
        guard let indexPath = watchGroupsView.tableView.indexPath(for: cell),
        let userID = Auth.auth().currentUser?.uid else { return }

        let pendingWatchGroup = pendingWatchGroups[indexPath.row]

        let batch = db.batch()
        let pendingGroupInviteDoc = db.collection("watch_group").document(userID).collection("invited").document(pendingWatchGroup.id)
        batch.deleteDocument(pendingGroupInviteDoc)

        let joinedWatchGroupDoc = db.collection("watch_group").document(userID).collection("joined").document(pendingWatchGroup.id)
        batch.setData(["id": pendingWatchGroup.id], forDocument: joinedWatchGroupDoc)

        let watchGroupInvitedUserDoc = db.collection("watch_groups").document(pendingWatchGroup.id).collection("users_invited").document(userID)
        batch.deleteDocument(watchGroupInvitedUserDoc)

        let watchGroupUserJoinedDoc = db.collection("watch_groups").document(pendingWatchGroup.id).collection("users_joined").document(userID)
        batch.setData(["user_id": userID], forDocument: watchGroupUserJoinedDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }

    func denyPressed(_ cell: RequestCell) {
        guard let indexPath = watchGroupsView.tableView.indexPath(for: cell),
            let userID = Auth.auth().currentUser?.uid else { return }

        let pendingWatchGroup = pendingWatchGroups[indexPath.row]

        let batch = db.batch()
        let pendingGroupInviteDoc = db.collection("watch_group").document(userID).collection("invited").document(pendingWatchGroup.id)
        batch.deleteDocument(pendingGroupInviteDoc)

        let watchGroupInvitedUserDoc = db.collection("watch_groups").document(pendingWatchGroup.id).collection("users_invited").document(userID)
        batch.deleteDocument(watchGroupInvitedUserDoc)

        batch.commit { error in
            if let error = error {
                print(error)
            }
        }
    }
}
