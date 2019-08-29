//
//  CreditViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class CreditViewController: UITableViewController {

    private let mediaManager: MediaManager
    private let credits: Credits

    init(mediaManager: MediaManager, credits: Credits) {
        self.mediaManager = mediaManager
        self.credits = credits
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        navigationItem.title = "Credits"
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = 120
        tableView.separatorColor = .white
        tableView.backgroundView = BlurBackgroundView()
        tableView.tableFooterView = UIView()
        tableView.register(CreditCell.self, forCellReuseIdentifier: "CreditCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return credits.cast.count
        } else {
            return credits.crew.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCell", for: indexPath) as! CreditCell

        let profilePath: String?
        let name: String
        let role: String

        if indexPath.section == 0 {
            let cast = credits.cast
            profilePath = cast[indexPath.row].profilePath
            name = cast[indexPath.row].name
            role = cast[indexPath.row].character
        } else {
            let crew = credits.crew
            profilePath = crew[indexPath.row].profilePath
            name = crew[indexPath.row].name
            role = crew[indexPath.row].job
        }

        cell.nameLabel.text = name
        cell.roleLabel.text = role

        if let profilePath = profilePath {
            cell.profileImageView.kf.indicatorType = .activity
            let activity = cell.profileImageView.kf.indicator?.view as! UIActivityIndicatorView
            activity.color = UIColor(named: "offYellow")
            let imageURL = mediaManager.getImageURL(for: .profile(path: profilePath, size: ImageEndpoint.ProfileSize.medium))
            cell.profileImageView.kf.setImage(with: imageURL)
        } else {
            cell.profileImageView.image = #imageLiteral(resourceName: "profile_na")
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 { return nil }

        switch section {
        case 0: return "Cast"
        case 1: return "Crew"
        default: return nil
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let person: PersonDisplayable = indexPath.section == 0 ? credits.cast[indexPath.row] : credits.crew[indexPath.row]
        let personMediaViewController = PersonMediaListViewController(person: person, mediaManager: mediaManager)
        navigationController?.pushViewController(personMediaViewController, animated: true)
    }
}
