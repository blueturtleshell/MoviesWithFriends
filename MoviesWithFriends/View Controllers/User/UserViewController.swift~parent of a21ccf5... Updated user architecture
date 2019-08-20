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

    private let mediaManager: MediaManager
    private let db = Firestore.firestore()
    private var user: MWFUser? {
        didSet {
            if let user = user {
                configureView(for: user)
            }
        }
    }

    private var bookmarkedMovies = [BookmarkMedia]()
    private var bookmarkedTV = [BookmarkMedia]()


    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
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

        fetchUser()

        fetchBookmarks()
    }

    //FIXME: change edit profile button target action
    private func setupView() {
        navigationItem.title = "User Profile"

        userView.editProfileButton.addTarget(self, action: #selector(logoutPrompt), for: .touchUpInside)

        userView.bookmarkSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)

        userView.tableView.delegate = self
        userView.tableView.dataSource = self
        userView.tableView.register(BookmarkCell.self, forCellReuseIdentifier: "BookmarkCell")
        userView.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        userView.tableView.tableFooterView = UIView()
        userView.tableView.separatorStyle = .none

        NotificationCenter.default.addObserver(self, selector: #selector(fetchUser), name: .userDidLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout), name: .userDidLogout, object: nil)

    }

    @objc private func segmentedControlChanged(_ segment: UISegmentedControl) {
        userView.tableView.reloadData()
    }

    @objc private func handleLogout(_ notification: Notification?) {
        user = nil
        tabBarController?.selectedIndex = 0
    }

    @objc private func logoutPrompt() {
        try? Auth.auth().signOut()
        handleLogout(nil)
    }

    @objc private func fetchUser(_ notification: Notification? = nil) {
        guard let userID = Auth.auth().currentUser?.uid, user == nil else { return }

        db.collection("users").document(userID).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
            } else if let userData = userSnapshot?.data(), let user = MWFUser(from: userData) {
                self.user = user
            }
        }
    }

    private func fetchBookmarks() {
        guard let userID = Auth.auth().currentUser?.uid, user == nil else { return }
        db.collection("bookmarks").document(userID).collection("media").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let bookmark = BookmarkMedia(from: diff.document.data()) else { return }
                        switch diff.type {
                        case .added:
                            switch bookmark.mediaType {
                            case .movie:
                                self.bookmarkedMovies.append(bookmark)
                            case .tv:
                                self.bookmarkedTV.append(bookmark)
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

    private func configureView(for user: MWFUser) {
        userView.fullNameLabel.text = user.fullName ?? ""
        if let profileURL = user.profileURL {
            userView.profileImageView.kf.indicatorType = .activity
            userView.profileImageView.kf.setImage(with: URL(string: profileURL))
        } else {
            userView.profileImageView.image = #imageLiteral(resourceName: "user")
        }
    }
}

extension UserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userView.bookmarkSegmentedControl.selectedSegmentIndex == 0 ? bookmarkedMovies.count : bookmarkedTV.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
