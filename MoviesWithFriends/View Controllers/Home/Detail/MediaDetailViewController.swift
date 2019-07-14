//
//  MediaDetailViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class MediaDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let detailView: MediaDetailView = {
        return MediaDetailView()
    }()

    private let mediaManager: MediaManager
    private let mediaType: MediaType
    private var mediaID: Int {
        didSet {
            fetchMedia()
        }
    }

    private var mediaInfo: MediaInfo? {
        didSet {
            if let mediaInfo = mediaInfo {
                configureView(for: mediaInfo)
            }
        }
    }

    private var similarMedia = [MediaDisplayable]()
    private var recommendedMedia = [MediaDisplayable]()
    private var mediaHistory = Stack<(id: Int, title: String?)>()

    init(mediaType: MediaType, mediaID: Int, mediaManager: MediaManager) {
        self.mediaType = mediaType
        self.mediaID = mediaID
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = detailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchMedia()
    }

    private func setupView() {
        detailView.relatedTableView.register(MediaRowCell.self, forCellReuseIdentifier: "MediaRow")
        detailView.relatedTableView.delegate = self
        detailView.relatedTableView.dataSource = self
        detailView.relatedTableView.rowHeight = 240
        detailView.relatedTableView.separatorColor = .clear
        detailView.relatedTableView.tableFooterView = UIView()
        //detailView.bookmarkButton.addTarget(self, action: #selector(bookmarkPressed), for: .touchUpInside)
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group", style: .plain, target: self, action: #selector(createGroup))

        detailView.creditButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        detailView.videosButton.addTarget(self, action: #selector(showVideos), for: .touchUpInside)
        detailView.backToPreviousMediaButton.addTarget(self, action: #selector(previousMediaButtonPressed), for: .touchUpInside)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func fetchMedia() {
        switch mediaType {
        case .movie:
            mediaManager.fetchMovieDetail(id: mediaID) { detailResult in
                do {
                    self.mediaInfo = try detailResult.get()
                } catch {
                    print(error)
                }
            }
        case .tv:
            print("")
        }
    }

    private func configureView(for mediaInfo: MediaInfo) {
        detailView.scrollView.contentOffset = CGPoint.zero

        detailView.titleLabel.text = mediaInfo.title
        detailView.certificationLabel.text = mediaInfo.rating
        detailView.releaseDateLabel.text = mediaInfo.releaseDate
        detailView.overviewLabel.text = mediaInfo.overview
        detailView.overviewLabel.setLineSpacing(lineHeightMultiple: 1.2)
        detailView.genreLabel.text = mediaInfo.genres.compactMap { $0.name }.joined(separator: ", ")

        detailView.backToPreviousMediaButton.isHidden = (mediaHistory.count < 1)
        detailView.backToPreviousMediaButton.setTitle("Back to \(mediaHistory.top?.title ?? "")", for: .normal)

        let score = mediaInfo.reviewScore ?? 0.0
        detailView.scoreButton.backgroundColor = getButtonColor(score: score)
        detailView.scoreButton.setTitle("\(score)", for: .normal)

        if let backdropPath = mediaInfo.backdropPath {
            detailView.backdropImageView.kf.indicatorType = .activity
            let url = mediaManager.getImageURL(for: ImageEndpoint.backdrop(path: backdropPath, size: .medium))
            detailView.backdropImageView.kf.setImage(with: url)
        }

        if let posterPath = mediaInfo.posterPath {
            detailView.posterImageView.kf.indicatorType = .activity
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            detailView.posterImageView.kf.setImage(with: imageURL)
        }

        getRelatedMedia(id: mediaInfo.id)
    }

    private func getRelatedMedia(id: Int) {
        mediaManager.fetchRelatedMedia(endpoint: .similar(mediaType: mediaType, id: id)) { similarMediaResult in
            do {
                self.similarMedia = try similarMediaResult.get().results
                self.detailView.relatedTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            } catch {
                print(error)
            }
        }
        mediaManager.fetchRelatedMedia(endpoint: .recommended(mediaType: mediaType, id: id)) { recommendedMediaResult in
            do {
                self.recommendedMedia = try recommendedMediaResult.get().results
                self.detailView.relatedTableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .automatic)
            } catch {
                print(error)
            }
        }
    }

    private func getButtonColor(score: Double) -> UIColor {
        var backgroundColor: UIColor
        switch score {
        case 1..<5:
            backgroundColor = UIColor(red:0.90, green:0.22, blue:0.21, alpha:1.0)
        case 5..<7:
            backgroundColor = UIColor(red:0.98, green:0.66, blue:0.15, alpha:1.0)
        case 7...:
            backgroundColor = UIColor(red:0.26, green:0.63, blue:0.28, alpha:1.0)
        default:
            backgroundColor = UIColor(red:0.46, green:0.46, blue:0.46, alpha:1.0)
        }
        return backgroundColor
    }

    // MARK: - Actions

    @objc func previousMediaButtonPressed(_ sender: UIButton) {
        guard let media = mediaHistory.pop() else { return }
        mediaID = media.id
    }

    @objc func showCredits() {
        guard let mediaInfo = mediaInfo else { return }
        let creditsViewController = CreditViewController(mediaManager: mediaManager, credits: mediaInfo.credits)
        navigationController?.pushViewController(creditsViewController, animated: true)
    }

    @objc func showVideos() {
        guard let mediaInfo = mediaInfo else { return }
        let videosViewController = VideosViewController(mediaManager: mediaManager, videos: mediaInfo.videos)
        navigationController?.pushViewController(videosViewController, animated: true)
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaRow", for: indexPath) as! MediaRowCell
        cell.seeAllButton.isHidden = true // TODO: maybe implement
        cell.delegate = self
        cell.mediaManager = mediaManager
        let media = (indexPath.row == 0 ? similarMedia : recommendedMedia)
        cell.titleLabel.text = indexPath.row == 0 ? "Similar Movies" : "If you liked \(mediaInfo?.title ?? "")"
        cell.titleLabel.textColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        cell.media = media
        cell.mediaCollectionView.reloadData()
        cell.mediaCollectionView.contentOffset = .zero
        return cell
    }
}

extension MediaDetailViewController: MediaRowDelegate {
    func didSelectMedia(media: MediaDisplayable) {
        mediaHistory.push((id: mediaID, title: mediaInfo?.title))
        mediaID = media.id
    }

    func seeAllPressed(endpoint: Endpoint) {
    }
}
