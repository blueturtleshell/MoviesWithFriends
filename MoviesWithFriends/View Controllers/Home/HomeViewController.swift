//
//  HomeViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/11/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let homeView: HomeView = {
        return HomeView()
    }()

    private let mediaManager: MediaManager
    private var currentMediaType: MediaType = .movie
    private var mediaDictionary = [Int: [Media]]()

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), tag: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = homeView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        homeView.tableView.rowHeight = 225
        homeView.tableView.delegate = self
        homeView.tableView.dataSource = self
        homeView.tableView.register(MediaRowCell.self, forCellReuseIdentifier: "MediaCell")
        fetchMedia()
    }

    private func fetchMedia() {
        for (index, endpoint) in currentMediaType.endpoints.enumerated() {
            mediaManager.fetchMedia(endpoint: endpoint, page: 1) { result in
                do {
                    let media = try result.get()
                    self.mediaDictionary[index] = media.results
                    self.homeView.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                } catch {
                    print(error)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMediaType.endpoints.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaCell", for: indexPath) as! MediaRowCell
        cell.mediaManager = mediaManager
        cell.delegate = self
        let endpoint = currentMediaType.endpoints[indexPath.row]
        cell.endpoint = endpoint
        cell.titleLabel.text = endpoint.description
        if let media =  mediaDictionary[indexPath.row] {
            cell.media = media
        }
        return cell
    }
}

extension HomeViewController: MediaRowDelegate {

    func didSelectMedia(media: MediaDisplayable) {
        let detailViewController = MediaDetailViewController(mediaType: currentMediaType, mediaID: media.id, mediaManager: mediaManager)
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func seeAllPressed(endpoint: Endpoint) {
        let mediaListViewController = MediaListViewController(mediaManager: mediaManager,
                                                              mediaType: currentMediaType, endpoint: endpoint)
        navigationController?.pushViewController(mediaListViewController, animated: true)
    }
}
