//
//  EditProfileViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 9/1/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    let editProfileView: EditProfileView = {
        return EditProfileView()
    }()

    override func loadView() {
        view = editProfileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
