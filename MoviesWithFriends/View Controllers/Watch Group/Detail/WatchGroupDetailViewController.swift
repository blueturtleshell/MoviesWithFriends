//
//  WatchGroupDetailViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/4/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class WatchGroupDetailViewController: UITableViewController {

    private lazy var titleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(watchGroup.name, for: .normal)
        button.addTarget(self, action: #selector(toggleTitle), for: .touchUpInside)
        return button
    }()

    private lazy var messageInputAccessoryView =  {
        return MessageInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    }()

    override var inputAccessoryView: UIView? {
        return messageInputAccessoryView
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    private let watchGroup: WatchGroup

    private let db = Firestore.firestore()
    private var usersInGroup = Set<MWFUser>()
    private var messages = [Message]()

    private var titleCycleIndex = 0

    init(watchGroup: WatchGroup) {
        self.watchGroup = watchGroup
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        configureView()
        fetchMessages()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        messageInputAccessoryView.isHidden = true
    }

    private func setupView() {
        tableView.keyboardDismissMode = .interactive

        navigationItem.titleView = titleButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Users", style: .plain, target: self, action: #selector(userOptions))

        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        tableView.register(MessageCell.self, forCellReuseIdentifier: "MessageCell")

        messageInputAccessoryView.messageTextView.delegate = self
        messageInputAccessoryView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)

        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(resignKeyboardFirstResponder))
        tableView.addGestureRecognizer(dismissKeyboardGesture)

        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func userOptions() {
        let userOptionsViewController = WatchGroupOptionsViewController(watchGroup: watchGroup)
        navigationController?.pushViewController(userOptionsViewController, animated: true)
    }

    @objc func adjustForKeyboard(_ notification: Notification) {
        guard let userInfo = notification.userInfo, messages.count > 3 else { return }

        // used to stop input accessory activating this function when setup
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue

        if beginFrame.equalTo(endFrame) {
            return
        }
        // end

        let keyboardViewEndFrame = view.convert(endFrameValue.cgRectValue, from: view.window)

        let keyboardOffset: CGPoint
        if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardOffset = CGPoint(x: 0, y: tableView.contentOffset.y -
                (keyboardViewEndFrame.height - messageInputAccessoryView.frame.height))
        } else {
            keyboardOffset = CGPoint(x: 0, y: tableView.contentOffset.y +
                (keyboardViewEndFrame.height - messageInputAccessoryView.frame.height))
        }

        tableView.setContentOffset(keyboardOffset, animated: false)
    }

    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy hh:mm a"
        return dateFormatter
    }()

    @objc private func toggleTitle() {
        titleCycleIndex += 1
        if titleCycleIndex > 2 {
            titleCycleIndex = 0
        }

        let titleText: String

        switch titleCycleIndex {
        case 0:
            titleText = watchGroup.name
        case 1:
            titleText = watchGroup.mediaTitle
        case 2:
            let date = Date(timeIntervalSince1970: watchGroup.dateInSeconds)
            titleText  = dateFormatter.string(from: date)
        default:
            titleText = "Error"
        }

        titleButton.setTitle(titleText, for: .normal)
        titleButton.sizeToFit()
    }

    private func configureView() {
        tableView.separatorStyle = .none
        tableView.backgroundColor = #colorLiteral(red: 0.9181943073, green: 0.9157902141, blue: 0.9577837344, alpha: 1)
    }

    @objc private func resignKeyboardFirstResponder() {
        messageInputAccessoryView.messageTextView.resignFirstResponder()
    }

    // MARK: - Firebase related

    @objc private func sendMessage(_ button: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid,
            let text = messageInputAccessoryView.messageTextView.text, !text.isEmpty else { return }

        let messageDoc = db.collection("watch_groups").document(watchGroup.id).collection("messages").document()
        let messageID = messageDoc.documentID

        let messageData: [String: Any] = ["id": messageID, "sender_id": userID,
                                          "text": text, "timestamp": FieldValue.serverTimestamp()]

        messageDoc.setData(messageData) { error in
            if let error = error {
                print(error)
            } else {
                self.messageInputAccessoryView.messageTextView.text = ""
                self.messageInputAccessoryView.textCountLabel.text = "0 / 100"
                self.messageInputAccessoryView.textCountLabel.isHidden = true
                self.messageInputAccessoryView.textCountLabel.textColor = .lightGray
                self.inputAccessoryView?.invalidateIntrinsicContentSize()
            }
        }
    }

    private func fetchMessages() {
        db.collection("watch_groups").document(watchGroup.id).collection("messages")
            .order(by: "timestamp", descending: false).addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error)
                } else {
                    if let snapshot = snapshot {
                        snapshot.documentChanges.forEach { diff in
                            guard let message = Message(from: diff.document.data()) else { return }
                            switch diff.type {
                            case .added, .modified: // timestamp not set in .added
                                self.messages.append(message)
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.insertRows(at: [indexPath], with: .bottom)
                                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                            default:
                                print(diff.type.rawValue)
                            }
                        }
                    }
                }
        }
    }

    // TableView

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell
        let message = messages[indexPath.row]
        cell.messageLabel.text = message.text

        if let user = usersInGroup.first(where: { user -> Bool in
            user.id == message.senderID
        }) {
            cell.userNameLabel.text = user.userName
            if let profilePath = user.profileURL {
                cell.profileImageView.kf.setImage(with: URL(string: profilePath))
            }
        } else {
            getUser(userID: message.senderID) { mwfUser in
                guard let user = mwfUser else { return }
                self.usersInGroup.insert(user)
                cell.userNameLabel.text = user.userName
                if let profilePath = user.profileURL {
                    cell.profileImageView.kf.setImage(with: URL(string: profilePath))
                }
            }
        }
        return cell
    }
}

// MARK: - TextField

extension WatchGroupDetailViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        guard messages.count > 3 else { return }
        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let oldText = textView.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: text) as NSString

        messageInputAccessoryView.textCountLabel.text = "\(newText.length) / 100"
        messageInputAccessoryView.sendButton.isEnabled = (newText.length > 0) && (newText.length <= 100)

        messageInputAccessoryView.textCountLabel.isHidden = newText.length == 0
        messageInputAccessoryView.textCountLabel.textColor = (newText.length > 0) && (newText.length <= 100) ? .lightGray : .red

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        inputAccessoryView?.invalidateIntrinsicContentSize()
    }
}
