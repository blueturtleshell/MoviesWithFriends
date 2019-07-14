//
//  VideosViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/13/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import SafariServices

class VideosViewController: UITableViewController {

    private let mediaManager: MediaManager
    private let videos: Videos
    private let headerTitles = ["Trailer", "Teaser", "Clip", "Featurette"]

    init(mediaManager: MediaManager, videos: Videos) {
        self.mediaManager = mediaManager
        self.videos = videos
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }

    private func setup() {
        navigationController?.title = "Videos"
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(VideoCell.self, forCellReuseIdentifier: "VideoCell")
        tableView.rowHeight = 80
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return headerTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.results.filter { video -> Bool in
            return video.type == headerTitles[section]
        }.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let video = videos.results.filter { video -> Bool in
            return video.type == headerTitles[indexPath.section]
        }[indexPath.row]
        cell.nameLabel.text = video.name
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard videos.results[indexPath.row].site.lowercased() == "youtube" else { return }
        if let url = URL(string: "https://www.youtube.com/watch?v=\(videos.results[indexPath.row].key)") {
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return nil
        } else {
            return headerTitles[section]
        }
    }
}

