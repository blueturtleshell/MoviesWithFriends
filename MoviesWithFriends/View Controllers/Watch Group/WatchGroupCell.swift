//
//  WatchGroupCell.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/31/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

class WatchGroupCell: UITableViewCell {

    private let containerView: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 4
        container.clipsToBounds = true
        return container
    }()

    let movieNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        return label
    }()

    let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    let groupNameLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = " "
        label.textColor = .black
        return label
    }()

    let userCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    var groupID: String? {
        didSet {
            getUsers()
        }
    }
    
    private var users = [MWFUser]()
    private let db = Firestore.firestore()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCell()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        users.removeAll()
        userCollectionView.reloadData()
        groupID = nil
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        addSubview(containerView)
        containerView.addSubview(posterImageView)
        containerView.addSubview(groupNameLabel)
        containerView.addSubview(movieNameLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(userCollectionView)

        userCollectionView.delegate = self
        userCollectionView.dataSource = self
        userCollectionView.register(MemberCell.self, forCellWithReuseIdentifier: "MemberCell")

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        posterImageView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(6)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 120))
        }

        groupNameLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        movieNameLabel.snp.makeConstraints { make in
            make.top.equalTo(groupNameLabel.snp.bottom).offset(4)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(movieNameLabel.snp.bottom).offset(4)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }

        userCollectionView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.bottom.equalTo(posterImageView)
            make.left.equalTo(posterImageView.snp.right).offset(12)
            make.right.equalToSuperview().inset(12)
        }
    }

    private func getUsers() {
        guard let groupID = groupID else { return }
        db.collection("watch_groups").document(groupID).collection("users_joined").addSnapshotListener { snapshot, error in
            if let error = error {
                print(error)
            } else {
                if let snapshot = snapshot {
                    snapshot.documentChanges.forEach { diff in
                        guard let userID = diff.document.data()["user_id"] as? String else { return }
                        getUser(userID: userID) { user in
                            guard let user = user else { return }
                            switch diff.type {
                            case .added:
                                let lastIndex = self.users.count
                                self.users.append(user)
                                self.userCollectionView.insertItems(at: [IndexPath(item: lastIndex, section: 0)])
                            case .removed:
                                if let index = self.users.firstIndex(of: user) {
                                    self.users.remove(at: index)
                                    self.userCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
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

extension WatchGroupCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count > 4 ? 4 : users.count // TODO: - display more ... cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! MemberCell

        if let profilePath = users[indexPath.item].profileURL {
            cell.profileImageView.kf.setImage(with: URL(string: profilePath))
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(users.count)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 40, height: 40)
    }
}
