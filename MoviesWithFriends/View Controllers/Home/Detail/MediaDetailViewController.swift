//
//  MediaDetailViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/12/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Firebase

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
    private var allowGroupCreation: Bool

    private var mediaInfo: MediaInfo? {
        didSet {
            if let mediaInfo = mediaInfo {
                configureView(for: mediaInfo)
                configureWatchGroupCreationButton()
            }
        }
    }

    private var similarMedia = [MediaDisplayable]()
    private var recommendedMedia = [MediaDisplayable]()
    private var mediaHistory = Stack<(id: Int, title: String?)>()
    private var isBookmarked = false {
        didSet {
            navigationItem.rightBarButtonItems = [createWatchGroupBarButtonItem, bookmarkBarButtonItem()]
        }
    }

    private func bookmarkBarButtonItem() -> UIBarButtonItem  {
        let imageName = isBookmarked ? "bookmark_fill" : "bookmark"
        let bookmarkImage = UIImage(named: imageName)
        let test = UIBarButtonItem(image: bookmarkImage, style: .plain, target: self, action: #selector(handleBookmarkButtonPressed))
        return test
    }

    private lazy var createWatchGroupBarButtonItem: UIBarButtonItem = {
        let createWatchGroup = UIBarButtonItem(image: #imageLiteral(resourceName: "group"), style: .plain, target: self, action: #selector(createGroup))
        return createWatchGroup
    }()

    init(mediaType: MediaType, mediaID: Int, mediaManager: MediaManager, allowGroupCreation: Bool = true) {
        self.mediaType = mediaType
        self.mediaID = mediaID
        self.mediaManager = mediaManager
        self.allowGroupCreation = allowGroupCreation
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMedia()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let mediaInfo = mediaInfo, let userID = Auth.auth().currentUser?.uid {
            if isBookmarked {
                mediaManager.bookmarkMedia(media: mediaInfo, mediaType: mediaType, userID: userID)
            } else {
                mediaManager.removeBookmarkMedia(media: mediaInfo, userID: userID)
            }
        }
    }

    private func setupView() {
        navigationItem.rightBarButtonItems = [createWatchGroupBarButtonItem, bookmarkBarButtonItem()]
        navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }

        detailView.scrollView.delegate = self

        detailView.relatedTableView.register(MediaRowCell.self, forCellReuseIdentifier: "MediaRow")
        detailView.relatedTableView.delegate = self
        detailView.relatedTableView.dataSource = self
        detailView.relatedTableView.rowHeight = 240
        detailView.relatedTableView.separatorColor = .clear
        detailView.relatedTableView.tableFooterView = UIView()

        detailView.creditButton.addTarget(self, action: #selector(showCredits), for: .touchUpInside)
        detailView.videosButton.addTarget(self, action: #selector(showVideos), for: .touchUpInside)
        detailView.backToPreviousMediaButton.addTarget(self, action: #selector(previousMediaButtonPressed), for: .touchUpInside)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    private func configureWatchGroupCreationButton() {
        let buttonEnabled: Bool
        if mediaHistory.count == 0 && !allowGroupCreation {
            buttonEnabled = false
        } else if mediaHistory.count > 0 {
            buttonEnabled = true
        } else {
            buttonEnabled = allowGroupCreation
        }

        createWatchGroupBarButtonItem.isEnabled = buttonEnabled && (Auth.auth().currentUser != nil)
        navigationItem.rightBarButtonItems = [createWatchGroupBarButtonItem, bookmarkBarButtonItem()]
    }

    @objc private func createGroup() {
        guard let mediaInfo = mediaInfo else { return }
        let watchGroupViewController = WatchGroupViewController(mediaType: mediaType, mediaInfo: mediaInfo, mediaManager: mediaManager)
        navigationController?.pushViewController(watchGroupViewController, animated: true)
    }

    private func fetchMedia() {

        let fetchHUD = HUDView.hud(inView: detailView, animated: true)
        fetchHUD.text = "Fetching Details"
        fetchHUD.accessoryType = .activityIndicator

        switch mediaType {
        case .movie:
            mediaManager.fetchMovieDetail(id: mediaID) { detailResult in
                do {
                    fetchHUD.remove(from: self.detailView)
                    self.mediaInfo = try detailResult.get()
                } catch {
                    print(error)
                }
            }
        case .tv:
            mediaManager.fetchTVShowDetail(id: mediaID) { detailResult in
                do {
                    fetchHUD.remove(from: self.detailView)
                    self.mediaInfo = try detailResult.get()
                } catch {
                    print(error)
                }
            }
        }
    }

    private func configureView(for mediaInfo: MediaInfo) {
        detailView.scrollView.contentOffset = CGPoint.zero

        if let userID = Auth.auth().currentUser?.uid {
            Firestore.firestore().collection("bookmarks").document(userID)
                .collection("media").document("\(mediaID)").addSnapshotListener { docSnapshot, error in
                    if let error = error {
                        print(error)
                    } else {
                        if let snapshot = docSnapshot {
                            self.isBookmarked = snapshot.exists
                        }
                    }
            }
        }

        detailView.titleLabel.text = mediaInfo.title
        detailView.certificationLabel.text = mediaInfo.rating

        let formattedReleaseDate: String
        if let releaseDate = mediaInfo.releaseDate, !releaseDate.isEmpty {
            formattedReleaseDate = releaseDate
        } else {
            formattedReleaseDate = "N/A"
        }

        detailView.releaseDateLabel.text = "Release Date: \(formattedReleaseDate)"
        detailView.overviewLabel.text = mediaInfo.overview
        detailView.overviewLabel.setLineSpacing(lineHeightMultiple: 1.2)
        if let runtime = mediaInfo.runtime {
            detailView.runtimeLabel.text = getFormattedRuntime(runtime)
        } else {
            detailView.runtimeLabel.text = "Runtime: N/A"
        }
        detailView.genreLabel.text = mediaInfo.genres.compactMap { $0.name }.joined(separator: ", ")

        detailView.backToPreviousMediaButton.isHidden = (mediaHistory.count < 1)
        detailView.backToPreviousMediaButton.setTitle("Back to \(mediaHistory.top?.title ?? "")", for: .normal)

        let score = mediaInfo.reviewScore ?? 0.0
        detailView.scoreButton.backgroundColor = getButtonColor(score: score)
        detailView.scoreButton.setTitle("\(score)", for: .normal)

        if let backdropPath = mediaInfo.backdropPath {
            detailView.backdropImageView.kf.indicatorType = .activity
            let activity = detailView.backdropImageView.kf.indicator?.view as! UIActivityIndicatorView
            activity.color = UIColor(named: "offYellow")
            let url = mediaManager.getImageURL(for: ImageEndpoint.backdrop(path: backdropPath, size: .medium))
            detailView.backdropImageView.kf.setImage(with: url)
        }
        
        if let posterPath = mediaInfo.posterPath, !posterPath.isEmpty {
            detailView.posterImageView.kf.indicatorType = .activity
            let activity = detailView.posterImageView.kf.indicator?.view as! UIActivityIndicatorView
            activity.color = UIColor(named: "offYellow")
            let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
            detailView.posterImageView.kf.setImage(with: imageURL)

            detailView.backgroundImageView.kf.indicatorType = .activity
            detailView.backgroundImageView.kf.setImage(with: imageURL)
        } else {
            detailView.posterImageView.layer.borderColor = UIColor.white.cgColor
            detailView.posterImageView.layer.borderWidth = 0.5
            detailView.posterImageView.image = #imageLiteral(resourceName: "image_na")
        }
        detailView.posterImageView.roundCornersForAspectFit(radius: 4)

        getRelatedMedia(id: mediaInfo.id)
    }

    private func getFormattedRuntime(_ runtime: Int) -> String {
        let hours = runtime / 60
        let minutes = runtime % 60
        if hours > 0 && minutes > 0 {
            return "Runtime: \(hours) \(hours > 1 ? "Hours" : "Hour") \(minutes) \(minutes > 1 ? "Minutes" : "Minute")"
        } else if hours >= 1 && minutes == 0 {
            return "Runtime: \(hours) \(hours > 1 ? "Hours" : "Hour")"
        }
        return "Runtime: \(minutes) \(minutes > 1 ? "Minutes" : "Minute")"
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

    @objc private func previousMediaButtonPressed(_ sender: UIButton) {
        guard let media = mediaHistory.pop() else { return }
        mediaID = media.id
    }

    @objc private func showCredits() {
        guard let mediaInfo = mediaInfo else { return }
        let creditsViewController = CreditViewController(mediaManager: mediaManager, credits: mediaInfo.credits)
        navigationController?.pushViewController(creditsViewController, animated: true)
    }

    @objc private func showVideos() {
        guard let mediaInfo = mediaInfo else { return }
        let videosViewController = VideosViewController(mediaManager: mediaManager, videos: mediaInfo.videos)
        navigationController?.pushViewController(videosViewController, animated: true)
    }

    @objc private func handleBookmarkButtonPressed() {
        isBookmarked.toggle()
    }

    // MARK: - TableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MediaRow", for: indexPath) as! MediaRowCell
        cell.seeAllButton.isHidden = true
        cell.delegate = self
        cell.mediaManager = mediaManager
        let media = (indexPath.row == 0 ? similarMedia : recommendedMedia)
        cell.titleLabel.text = indexPath.row == 0 ? "Related" : "If you liked \(mediaInfo?.title ?? "")"
        cell.media = media
        cell.mediaCollectionView.reloadData()
        cell.mediaCollectionView.contentOffset = .zero
        return cell
    }
}

extension MediaDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            detailView.backdropImageView.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
        }
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
