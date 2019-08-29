//
//  UserViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class UserViewController: UIViewController {

    let userView: UserView = {
        return UserView()
    }()

    private let user: MWFUser?
    private let mediaManager = MediaManager()
    private let db = Firestore.firestore()

    private var bookmarkedMovies = [BookmarkMedia]()
    private var bookmarkedTV = [BookmarkMedia]()
    private var bookmarkListener: ListenerRegistration?

    private var isBookmarkPublic = true {
        didSet {
            userView.tableView.reloadData()
        }
    }


    init(user: MWFUser?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "User", image: UIImage(named: "user"), tag: 3)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = userView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureForUser()
    }

    private func setupView() {
        navigationItem.title = "User Profile"

        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpFirestoreListeners), name: .userDidLogout, object: nil)

        userView.editProfileButton.addTarget(self, action: #selector(handleLogoutButtonPressed), for: .touchUpInside)
        userView.settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        userView.bookmarkSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)

        userView.tableView.delegate = self
        userView.tableView.dataSource = self
        userView.tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
        userView.tableView.register(BookmarkCell.self, forCellReuseIdentifier: "BookmarkCell")
        userView.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        userView.tableView.tableFooterView = UIView()
        userView.tableView.separatorStyle = .none
    }

    @objc private func cleanUpFirestoreListeners(_ notification: Notification) {
        bookmarkListener?.remove()
    }

    @objc private func handleLogoutButtonPressed() {
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }

    @objc private func settingsButtonPressed() {
        guard let user = user else { return }
        
        let settingsViewController = SettingsViewController(user: user)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @objc private func segmentedControlChanged(_ segment: UISegmentedControl) {
        userView.tableView.reloadData()
    }

    private func configureForUser() {
        guard let user = user else { return }

        userView.fullNameLabel.text = user.fullName ?? ""
        if let profileURL = user.profileURL {
            userView.profileImageView.kf.indicatorType = .activity
            userView.profileImageView.kf.setImage(with: URL(string: profileURL))
        } else {
            userView.profileImageView.image = #imageLiteral(resourceName: "user")
        }

        if let currentUserID = Auth.auth().currentUser?.uid, currentUserID != user.id {
            userView.settingsButton.isHidden = true
            userView.editProfileButton.isHidden = true

            db.collection("user_settings").document(user.id).getDocument { settingsDocument, error in
                if let error = error {
                    print(error)
                } else {
                    if let settingsDocument = settingsDocument {
                        self.isBookmarkPublic = settingsDocument.data()?["bookmark_public"] as? Bool ?? false
                    }
                }
            }
        } else {
            fetchBookmarks()
        }
    }

    private func fetchBookmarks() {
        guard let userID = user?.id else { return }
        bookmarkListener = db.collection("bookmarks").document(userID).collection("media").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
                self.bookmarkListener?.remove()
                return
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let bookmark = BookmarkMedia(from: diff.document.data()) else { return }
                        switch diff.type {
                        case .added:
                            switch bookmark.mediaType {
                            case .movie:
                                self.bookmarkedMovies.append(bookmark)
                                self.bookmarkedMovies.sort(by: <)
                            case .tv:
                                self.bookmarkedTV.append(bookmark)
                                self.bookmarkedTV.sort(by: <)
                            }
                            self.userView.tableView.reloadData()
                        case .removed:
                            switch bookmark.mediaType {
                            case .movie:
                                if let index = self.bookmarkedMovies.firstIndex(of: bookmark) {
                                    self.bookmarkedMovies.remove(at: index)
                                }
                            case .tv:
                                if let index = self.bookmarkedTV.firstIndex(of: bookmark) {
                                    self.bookmarkedTV.remove(at: index)
                                }
                            }
                            self.userView.tableView.reloadData()
                        default:
                            print(diff.type.rawValue)
                        }
                    }
                }
            }
        }
    }
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !isBookmarkPublic {
            return 1
        }
        return userView.bookmarkSegmentedControl.selectedSegmentIndex == 0 ? bookmarkedMovies.count : bookmarkedTV.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if !isBookmarkPublic {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
            cell.emptyTextLabel.text = "Private"
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as! BookmarkCell

        let media = userView.bookmarkSegmentedControl.selectedSegmentIndex == 0 ?
            bookmarkedMovies[indexPath.row] : bookmarkedTV[indexPath.row]
        
        cell.mediaTitleLabel.text = media.title

        if let posterPath = media.posterPath {
            let url = mediaManager.getImageURL(for: ImageEndpoint.poster(path: posterPath, size: .small))
            cell.posterImageView.kf.setImage(with: url)
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard isBookmarkPublic else { return }

        let media = userView.bookmarkSegmentedControl.selectedSegmentIndex == 0 ?
            bookmarkedMovies[indexPath.row] : bookmarkedTV[indexPath.row]
        let mediaDetailViewController = MediaDetailViewController(mediaType: media.mediaType, mediaID: media.id, mediaManager: mediaManager)
        navigationController?.pushViewController(mediaDetailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let userID = Auth.auth().currentUser?.uid else { return }
        let media = userView.bookmarkSegmentedControl.selectedSegmentIndex == 0 ?
            bookmarkedMovies[indexPath.row] : bookmarkedTV[indexPath.row]

        db.collection("bookmarks").document(userID).collection("media").document("\(media.id)").delete { error in
            if let error = error {
                print(error)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
