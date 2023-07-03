//
//  UserHelper.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation
import Firebase

func getUser(userID: String, completion: @escaping (MWFUser?) -> Void) {
    Firestore.firestore().collection("users").document(userID).getDocument { userSnapshot, error in
        if let error = error {
            print(error)
            completion(nil)
        } else if let snapshot = userSnapshot, let userData = snapshot.data() {
            completion(MWFUser(from: userData))
        }
    }
}

func getWatchGroup(groupID: String, completion: @escaping (WatchGroup?) -> Void) {
    Firestore.firestore().collection("watch_groups").document(groupID).getDocument { groupSnapshot, error in
        if let error = error {
            print(error)
            completion(nil)
        } else if let snapshot = groupSnapshot, let groupData = snapshot.data() {
            completion(WatchGroup(from: groupData))
        } else {
            print("error")
        }
    }
}

func uploadImage(imageData: Data, imageName: String? = nil, storageFolder: String, completion: @escaping (Result<URL?, Error>) -> Void) {
    let filename = imageName ?? UUID().uuidString
    let storageRef = Storage.storage().reference(withPath: "/\(storageFolder)/\(filename)")
    storageRef.putData(imageData, metadata: nil, completion: { (_, error) in
        if let error = error {
            completion(.failure(error))
            return
        }

        storageRef.downloadURL(completion: { (url, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(url))
        })
    })
}
