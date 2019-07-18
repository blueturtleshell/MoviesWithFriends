//
//  SearchViewController.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate,
UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegateFlowLayout {

    let searchView: SearchView = {
        return SearchView()
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Search..."
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        return searchController
    }()

    private let mediaManager: MediaManager

    private var searchTerm = "" {
        didSet {
            resetSearch()
        }
    }
    private var hasSearched = false
    private var currentPage = 1
    private var totalPages = Int.max
    private var media = [MediaDisplayable]()
    private var people = [PersonDisplayable]()

    init(mediaManager: MediaManager) {
        self.mediaManager = mediaManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        searchView.collectionView.delegate = self
        searchView.collectionView.dataSource = self
        searchView.collectionView.prefetchDataSource = self

        searchView.collectionView.register(PosterCell.self, forCellWithReuseIdentifier: "PosterCell")
        searchView.collectionView.register(NothingFoundCell.self, forCellWithReuseIdentifier: "NothingFoundCell")
        searchView.segmentedControl.addTarget(self, action: #selector(searchSegmentChanged), for: .valueChanged)
    }

    private func resetSearch() {
        currentPage = 1
        totalPages = Int.max

        media.removeAll()
        people.removeAll()
        searchView.collectionView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        hasSearched = true
        searchTerm = searchText

        switch searchView.segmentedControl.selectedSegmentIndex {
        case 0, 1:
            searchForMedia()
        default:
            searchForPerson()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hasSearched = false
        resetSearch()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if hasSearched && searchText == "" {
            print("X was pressed")
            searchTerm = ""
            hasSearched = false
            resetSearch()
        }
    }

    @objc private func searchSegmentChanged(_ sender: UISegmentedControl) {
        guard !searchTerm.isEmpty else { return }

        resetSearch()

        if sender.selectedSegmentIndex == 0 || sender.selectedSegmentIndex == 1 {
            searchForMedia()
        } else {
            searchForPerson()
        }
    }

    private func searchForMedia() {
        guard !searchTerm.isEmpty && currentPage < totalPages else { return }

        if searchView.segmentedControl.selectedSegmentIndex == 0 {
            mediaManager.searchForMovie(text: searchTerm, page: currentPage) { result in
                do {
                    let searchResult = try result.get()
                    self.currentPage = searchResult.page + 1
                    self.totalPages = searchResult.totalPages
                    self.media += searchResult.results
                    self.searchView.collectionView.reloadData()
                } catch {
                    print(error)
                }
            }
        } else {
            mediaManager.searchForTVShow(text: searchTerm, page: currentPage) { result in
                do {
                    let searchResult = try result.get()
                    self.currentPage = searchResult.page + 1
                    self.totalPages = searchResult.totalPages
                    self.media += searchResult.results
                    self.searchView.collectionView.reloadData()
                } catch {
                    print(error)
                }
            }
        }
    }

    private func searchForPerson() {
        guard !searchTerm.isEmpty && currentPage < totalPages else { return }

        mediaManager.searchForPerson(name: searchTerm, page: currentPage) { result in
            do {
                let searchResult = try result.get()
                self.currentPage = searchResult.page + 1
                self.totalPages = searchResult.totalPages
                self.people += searchResult.results
                self.searchView.collectionView.reloadData()
            } catch {
                print(error)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchView.segmentedControl.selectedSegmentIndex == 0 || searchView.segmentedControl.selectedSegmentIndex == 1 {
            if media.isEmpty {
                return 1
            }
            return media.count
        } else {
            if people.isEmpty {
                return 1
            }
            return people.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchView.segmentedControl.selectedSegmentIndex == 0 || searchView.segmentedControl.selectedSegmentIndex == 1 {
            if media.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NothingFoundCell", for: indexPath) as! NothingFoundCell
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

            let mediaItem = media[indexPath.item]
            cell.titleLabel.text = mediaItem.title

            if let posterPath = mediaItem.posterPath {
                cell.posterImageView.kf.indicatorType = .activity
                let imageURL = mediaManager.getImageURL(for: .poster(path: posterPath, size: ImageEndpoint.PosterSize.medium))
                cell.posterImageView.kf.setImage(with: imageURL)
            }
            return cell
        } else {
            if people.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NothingFoundCell", for: indexPath) as! NothingFoundCell
                cell.textLabel.textColor = .black // FIXME: change when background color changes
                return cell
            }

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PosterCell", for: indexPath) as! PosterCell

            let person = people[indexPath.item]
            cell.titleLabel.text = person.name

            if let profilePath = person.profilePath {
                cell.posterImageView.kf.indicatorType = .activity
                let imageURL = mediaManager.getImageURL(for: .profile(path: profilePath, size: ImageEndpoint.ProfileSize.medium))
                cell.posterImageView.kf.setImage(with: imageURL)
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (searchView.segmentedControl.selectedSegmentIndex == 0 || searchView.segmentedControl.selectedSegmentIndex == 1) &&
            media.isEmpty {
            return
        } else if searchView.segmentedControl.selectedSegmentIndex == 2 && people.isEmpty {
            return
        }

        if searchView.segmentedControl.selectedSegmentIndex == 0 {
            let mediaDetailViewController = MediaDetailViewController(mediaType: .movie,
                                                                      mediaID: media[indexPath.row].id, mediaManager: mediaManager)
            navigationController?.pushViewController(mediaDetailViewController, animated: true)
        } else if searchView.segmentedControl.selectedSegmentIndex == 1 {
            let mediaDetailViewController = MediaDetailViewController(mediaType: .tv,
                                                                      mediaID: media[indexPath.row].id, mediaManager: mediaManager)
            navigationController?.pushViewController(mediaDetailViewController, animated: true)
        } else {
            let person = people[indexPath.item]
            let personMediaViewController = PersonMediaListViewController(person: person, mediaManager: mediaManager)
            navigationController?.pushViewController(personMediaViewController, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if searchView.segmentedControl.selectedSegmentIndex == 0 || searchView.segmentedControl.selectedSegmentIndex == 1 {
            let containedIndexPathItems = indexPaths.filter { $0.item == media.count - 1}.count
            if containedIndexPathItems > 0 {
                searchForMedia()
            }
        } else {
            let containedIndexPathItems = indexPaths.filter { $0.item == people.count - 1}.count
            if containedIndexPathItems > 0 {
                searchForPerson()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if (searchView.segmentedControl.selectedSegmentIndex == 0 || searchView.segmentedControl.selectedSegmentIndex == 1) &&
            media.isEmpty {
            return CGSize(width: view.bounds.width, height: 180)
        } else if searchView.segmentedControl.selectedSegmentIndex == 2 && people.isEmpty {
            return CGSize(width: view.bounds.width, height: 180)
        }

        let cellWidth = view.bounds.width / 2.0
        let cellHeight = cellWidth * 1.66
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
