//
//  FriendViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/22/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

enum FriendRequestState {
    case empty
    case validUser(user: MWFUser)
    case requestSent
    case error(message: String)

    var message: String? {
        switch self {
        case .empty, .validUser: return nil
        case .requestSent: return "Friend Request sent"
        case .error(let message): return message
        }
    }
}

class FriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let friendView: FriendView = {
        return FriendView()
    }()

    private var currentUser: MWFUser

    private let db = Firestore.firestore()

    private var requestState: FriendRequestState = .empty {
        didSet {
            friendView.messageLabel.text = requestState.message

            DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
                guard let self = self else { return }
                self.friendView.messageLabel.text = nil
            }
        }
    }
    private var requestsPending = [MWFUser]()

    init(user: MWFUser) {
        currentUser = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = friendView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchPendingFriendRequests()
    }

    private func setupView() {
        friendView.tableView.delegate = self
        friendView.tableView.dataSource = self
        friendView.tableView.register(EmptyCell.self, forCellReuseIdentifier: "EmptyCell")
        friendView.tableView.register(AddUserCell.self, forCellReuseIdentifier: "AddUserCell")
        friendView.tableView.register(PendingCell.self, forCellReuseIdentifier: "PendingCell")

        friendView.friendCodeTextField.delegate = self
        friendView.dismissButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        friendView.confirmButton.addTarget(self, action: #selector(requestUser), for: .touchUpInside)
    }

    @objc private func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func requestUser() {
        friendView.friendCodeTextField.resignFirstResponder()

        guard let friendCodeText = friendView.friendCodeTextField.text, !friendCodeText.isEmpty else { return }
        let friendCode = friendCodeText.trimmingCharacters(in: .whitespacesAndNewlines)
        friendView.friendCodeTextField.text = nil

        db.collection("friend_codes").document(friendCode).getDocument { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot, snapshot.exists, let friendCodeDict = snapshot.data(),
                    let userID = friendCodeDict["user_id"] as? String {

                    self.db.collection("users").document(userID).getDocument(completion: { userSnapshot, error in
                        if let error = error {
                            print(error)
                        } else {
                            if let userSnapshot = userSnapshot, let userData = userSnapshot.data(),
                                let user = MWFUser(from: userData) {

                                if let currentUserID = Auth.auth().currentUser?.uid, currentUserID == user.id {
                                    self.requestState = .error(message: "This is your Friend Code.")
                                } else if self.checkIfUserIsPending(userID: user.id) {
                                    self.requestState = .error(message: "Already requested to be friends.")
                                }
                                else {
                                    self.checkifFriends(user) { isFriends in
                                        if !isFriends {
                                            self.requestState = .validUser(user: user)
                                            self.friendView.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .left)
                                        } else {
                                            self.requestState = .error(message: "You are already friends.")
                                        }
                                    }
                                }
                            }
                        }
                    })
                } else {
                    self.requestState = .error(message: "Friend Code not associated to a user.")
                }
            }
        }
    }

    private func checkifFriends(_ otherUser: MWFUser, completion: @escaping (Bool) -> Void) {
        db.collection("relationships").document(currentUser.id).collection("friends").document(otherUser.id).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
                completion(false)
            } else {
                completion(userSnapshot?.exists ?? false)
            }
        }
    }

    private func checkIfUserIsPending(userID: String) -> Bool {
        return requestsPending.contains(where: { pendingRequestUser -> Bool in
            return pendingRequestUser.id == userID
        })
    }

    private func fetchPendingFriendRequests() {
        db.collection("relationships").document(currentUser.id).collection("pending").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    snapshot.documents.forEach { self.getUser(from: $0.data()) }
                }
            }
        }
    }

    private func getUser(from dict: [String: Any]) {
        guard let userID = dict["user_id"] as? String else { return }

        db.collection("users").document(userID).getDocument { userSnapshot, error in
            if let error = error {
                print(error)
            } else if let snapshot = userSnapshot, let userData = snapshot.data(),
                let user = MWFUser(from: userData) {
                self.requestsPending.append(user)
                self.friendView.tableView.reloadSections(IndexSet(integer: 1), with: .left)
            }
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return requestsPending.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if case let FriendRequestState.validUser(user) = requestState {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddUserCell", for: indexPath) as! AddUserCell
                cell.delegate = self

                cell.userNameLabel.text = user.userName
                cell.fullNameLabel.text = user.fullName

                if let profileImagePath = user.profileURL {
                    cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EmptyCell", for: indexPath) as! EmptyCell
                cell.backgroundColor = .clear
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PendingCell", for: indexPath) as! PendingCell
            cell.delegate = self

            let user = requestsPending[indexPath.row]

            cell.userNameLabel.text = user.userName
            cell.fullNameLabel.text = user.fullName

            if let profileImagePath = user.profileURL {
                cell.profileImageView.kf.setImage(with: URL(string: profileImagePath))
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        } else {
            return 125
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Pending"
        }
        return nil
    }
}

extension FriendViewController: AddUserCellDelegate {
    func sendRequestPressed(_ cell: AddUserCell) {
        if case let FriendRequestState.validUser(requestedUser) = requestState {
            let batch = db.batch()

            // current user add requested user to pending collection
            let currentUserRequestDoc = db.collection("relationships").document(currentUser.id).collection("pending").document(requestedUser.id)
            batch.setData(["user_id": requestedUser.id], forDocument: currentUserRequestDoc)

            // request user add current user id to request collection
            let requestedUserDoc = db.collection("relationships").document(requestedUser.id).collection("request").document(currentUser.id)
            batch.setData(["user_id": currentUser.id], forDocument: requestedUserDoc)

            batch.commit { error in
                if let error = error {
                    print(error)
                } else {
                    self.requestState = .requestSent
                    self.friendView.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .right)
                }
            }
        }
    }

    func cancelPressed(_ cell: AddUserCell) {
        requestState = .empty
        friendView.tableView.reloadRows(at: [IndexPath(item: 0, section: 0)], with: .right)
    }
}

extension FriendViewController: PendingCellDelegate {
    func acceptPressed(_ cell: PendingCell) {

    }

    func denyPressed(_ cell: PendingCell) {

    }
}

extension FriendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
