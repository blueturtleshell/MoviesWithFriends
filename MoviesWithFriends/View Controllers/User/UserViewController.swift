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

    private let user: MWFUser
    private let mediaManager = MediaManager()
    private let db = Firestore.firestore()

    private var bookmarkedMovies = [BookmarkMedia]()
    private var bookmarkedTV = [BookmarkMedia]()
    private var bookmarkListener: ListenerRegistration?

    private var isFriendsPublic = true
    private var isWatchGroupsPublic = true
    private var isBookmarkPublic = true {
        didSet {
            userView.tableView.reloadData()
        }
    }

    init(user: MWFUser) {
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

        if let currentUserID = Auth.auth().currentUser?.uid, currentUserID == user.id {
            let settingsButton = UIBarButtonItem(image: #imageLiteral(resourceName: "settings"), style: .plain, target: self, action: #selector(settingsButtonPressed))
            navigationItem.rightBarButtonItem = settingsButton

            let changeProfileTapGesture = UITapGestureRecognizer(target: self, action: #selector(showChangeImageAlert))
            userView.profileImageView.addGestureRecognizer(changeProfileTapGesture)

            userView.fullInfoStackView.isHidden = true // current user does not have to see this
        }

        NotificationCenter.default.addObserver(self, selector: #selector(cleanUpFirestoreListeners), name: .userDidLogout, object: nil)


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

    @objc private func showChangeImageAlert() {
        let alertController = UIAlertController(title: "Change Profile Image", message: "Are you sure?", preferredStyle: .actionSheet)
        let confirmAction = UIAlertAction(title: "Change profile image", style: .destructive, handler: changeImage)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc private func changeImage(_ action: UIAlertAction) {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func settingsButtonPressed() {
        guard let currentUserID = Auth.auth().currentUser?.uid, currentUserID == user.id else { return }
        
        let settingsViewController = SettingsViewController(user: user)
        navigationController?.pushViewController(settingsViewController, animated: true)
    }

    @objc private func segmentedControlChanged(_ segment: UISegmentedControl) {
        userView.tableView.reloadData()
    }

    private func configureForUser() {
        userView.fullNameLabel.text = user.fullName ?? user.userName
        if let profileURL = user.profileURL {
            userView.profileImageView.kf.indicatorType = .activity
            userView.profileImageView.kf.setImage(with: URL(string: profileURL))
        } else {
            userView.profileImageView.image = #imageLiteral(resourceName: "user")
        }

        // not the current user, ie friend page
        if let currentUserID = Auth.auth().currentUser?.uid, currentUserID != user.id {
            db.collection("user_settings").document(user.id).getDocument { settingsDocument, error in
                if let error = error {
                    print(error)
                } else {
                    if let settingsDocument = settingsDocument {
                        self.isBookmarkPublic = settingsDocument.data()?["bookmark_public"] as? Bool ?? false
                        self.isFriendsPublic = settingsDocument.data()?["friends_public"] as? Bool ?? false
                        self.isWatchGroupsPublic = settingsDocument.data()?["watch_groups_public"] as? Bool ?? false

                        if self.isBookmarkPublic {
                            self.fetchBookmarks()
                        }

                        // get friends count, if not public show lock and unable to click
                        self.db.collection("relationships").document(self.user.id).collection("friends").getDocuments(completion: { snapshot, error in
                            if let error = error {
                                print(error)
                            } else {
                                if let snapshot = snapshot {
                                    self.userView.friendCountView.set(text: "\(snapshot.count)", isPublic: self.isFriendsPublic)
                                }
                            }
                        })

                        // get watch group count, if not public show lock and unable to click
                        self.db.collection("watch_group").document(self.user.id).collection("joined").getDocuments(completion: { snapshot, error in
                            if let error = error {
                                print(error)
                            } else {
                                if let snapshot = snapshot {
                                    self.userView.watchGroupCountView.set(text: "\(snapshot.count)", isPublic: self.isWatchGroupsPublic)
                                }
                            }
                        })
                    }
                }
            }
        } else {
            fetchBookmarks()
        }
    }

    private func fetchBookmarks() {
        bookmarkListener = db.collection("bookmarks").document(user.id).collection("media").addSnapshotListener { snapshot, error in
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

    @objc fileprivate func changeProfileImage(with image: UIImage, completion: @escaping () -> Void) {
        if let imageData = image.jpegData(compressionQuality: 0.4) {
            uploadImage(imageData: imageData, imageName: user.id, storageFolder: "profile_images") { uploadResult in
                do {
                    let profileImageURL = try uploadResult.get()
                    self.db.document("users/\(self.user.id)").updateData(["profile_image": profileImageURL?.absoluteString ?? ""], completion: { error in
                        if let error = error {
                            print(error)
                        } else {
                            completion()
                        }
                    })
                } catch {
                    print(error)
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

extension UserViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        userView.profileImageView.image = image

        let uploadImageHUD = HUDView.hud(inView: picker.view, animated: true)
        uploadImageHUD.text = "Uploading Image"
        uploadImageHUD.accessoryType = .activityIndicator

        changeProfileImage(with: image) {
            uploadImageHUD.remove(from: picker.view)
            self.dismiss(animated: true, completion: nil)
        }
    }
}
