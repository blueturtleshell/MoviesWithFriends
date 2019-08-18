//
//  UserManager.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 8/17/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import Foundation
import Firebase

class UserManager {
    private(set) var currentUser: MWFUser?

    var isLoggedIn: Bool {
        return currentUser != nil
    }

    init() {
    }

    func setup() {
        if let _ = Auth.auth().currentUser {
            NotificationCenter.default.post(name: .userDidLogin, object: nil, userInfo: nil)
        } else {
            currentUser = nil
        }
    }

    func retrieveUser(completion: @escaping () -> Void) {
        guard !isLoggedIn, let userID = Auth.auth().currentUser?.uid else { return } // user already logged in

        getUser(userID: userID) { user in
            self.currentUser = user
            completion()
        }
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            currentUser = nil
        } catch {
            print("error logging user out")
        }
    }
}
