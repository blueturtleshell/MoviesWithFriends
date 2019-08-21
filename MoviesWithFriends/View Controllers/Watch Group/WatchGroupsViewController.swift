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

    private let mediaManager = MediaManager()
    private let currentUser: MWFUser

    private var db = Firestore.firestore()
    private var watchGroupJoinedListener: ListenerRegistration?
    private var watchGroupInvitedListener: ListenerRegistration?

    private var joinedWatchGroups = [WatchGroup]()
    private var pendingWatchGroups = [WatchGroup]()

    private var didFetch = false

    init(user: MWFUser) {
        self.currentUser = user
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !didFetch {
            fetchWatchGroups()
            didFetch = true
        }
    }

    private func setupView() {
        navigationItem.title = "Watch Groups"
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ticket"), style: .plain, target: self, action: #selector(createCustomWatchGroup))

        watchGroupsView.tableView.dataSource = self
        watchGroupsView.tableView.delegate = self
        watchGroupsView.tableView.tableFooterView = UIView()
        watchGroupsView.tableView.register(WatchGroupCell.self, forCellReuseIdentifier: "WatchGroupCell")
        watchGroupsView.tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
        watchGroupsView.tableView.register(WatchGroupInviteCell.self, forCellReuseIdentifier: "WatchGroupInviteCell")

        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpFirestoreListeners), name: .userDidLogout, object: nil)
    }

    @objc private func createCustomWatchGroup() {

    }

    @objc private func cleanUpFirestoreListeners(_ notification: Notification) {
        watchGroupJoinedListener?.remove()
        watchGroupInvitedListener?.remove()
    }

    private func fetchWatchGroups() {
        let fetchingHUD = HUDView.hud(inView: watchGroupsView, animated: true)
        fetchingHUD.text = "Fetching Groups"
        fetchingHUD.accessoryType = .activityIndicator

        watchGroupJoinedListener = db.collection("watch_group").document(currentUser.id).collection("joined").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
                return
            } else {
                if let snapshot = snapshot {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                        fetchingHUD.remove(from: self.watchGroupsView)
                    })

                    if snapshot.documents.count == 0 {
                        self.watchGroupsView.tableView.reloadData()
                        return
                    }

                    snapshot.documentChanges.forEach { diff in
                        guard let groupID = diff.document.data()["id"] as? String else { return }
                        getWatchGroup(groupID: groupID) { watchGroup in
                            guard let watchGroup = watchGroup else { return }

                            switch diff.type {
                            case .added:
                                let groupCount = self.joinedWatchGroups.count
                                self.joinedWatchGroups.append(watchGroup)
                                self.watchGroupsView.tableView.insertRows(at: [IndexPath(row: groupCount, section: 0)], with: .none)

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

        watchGroupInvitedListener = db.collection("watch_group").document(currentUser.id).collection("invited").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
                return
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let groupID = diff.document.data()["id"] as? String else { return }
                        getWatchGroup(groupID: groupID) { watchGroup in
                            guard let watchGroup = watchGroup else { return }

                            switch diff.type {
                            case .added:
                                let index = self.pendingWatchGroups.count
                                self.pendingWatchGroups.append(watchGroup)
                                self.watchGroupsView.tableView.insertRows(at: [IndexPath(row: index, section: 1)], with: .none)
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
            return joinedWatchGroups.count
        }
        return pendingWatchGroups.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchGroupCell", for: indexPath) as! WatchGroupCell
            cell.delegate = self
            let group = joinedWatchGroups[indexPath.row]

            cell.groupNameLabel.text = group.name
            cell.movieNameLabel.text = group.mediaTitle
            cell.dateLabel.text = group.displayDate

            if let posterImagePath = group.posterPath {
                let posterURL = mediaManager.getImageURL(for: .poster(path: posterImagePath, size: .medium))
                cell.posterImageView.kf.setImage(with: posterURL)
            }

            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WatchGroupInviteCell", for: indexPath) as! WatchGroupInviteCell
            cell.delegate = self
            let pendingGroup = pendingWatchGroups[indexPath.row]

            cell.groupNameLabel.text = pendingGroup.name
            cell.dateLabel.text = pendingGroup.displayDate

            getUser(userID: pendingGroup.creatorID) { user in
                if let user = user {
                    cell.invitedLabel.text = "Invited by: \(user.fullName ?? user.userName)"
                }
            }

            if let posterImagePath = pendingGroup.posterPath {
                let posterURL = mediaManager.getImageURL(for: .poster(path: posterImagePath, size: .medium))
                cell.posterImageView.kf.setImage(with: posterURL)
            }

            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }

        let groupDetailViewController = WatchGroupDetailViewController(watchGroup: joinedWatchGroups[indexPath.row])
        navigationController?.pushViewController(groupDetailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if joinedWatchGroups.isEmpty {
                return 250
            }
        }
        return 154
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 52
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let inviteHeader = InviteHeaderView()
            return inviteHeader
        }
        return nil
    }

    func displayMediaDetails(for watchGroup: WatchGroup) {
        let mediaDetailViewController = MediaDetailViewController(mediaType: watchGroup.type,
                                                                  mediaID: watchGroup.mediaID, mediaManager: mediaManager, allowGroupCreation: false)
        navigationController?.pushViewController(mediaDetailViewController, animated: true)
    }
}

extension WatchGroupsViewController: WatchGroupCellDelegate {
    func infoButtonPressed(_ cell: WatchGroupCell) {
        guard let indexPath = watchGroupsView.tableView.indexPath(for: cell) else { return }
        displayMediaDetails(for: joinedWatchGroups[indexPath.row])
    }
}

extension WatchGroupsViewController: WatchGroupInviteCellDelegate {

    func infoButtonPressed(_ cell: WatchGroupInviteCell) {
        guard let indexPath = watchGroupsView.tableView.indexPath(for: cell) else { return }

        displayMediaDetails(for: pendingWatchGroups[indexPath.row])
    }

    func acceptPressed(_ cell: WatchGroupInviteCell) {
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

    func denyPressed(_ cell: WatchGroupInviteCell) {
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
