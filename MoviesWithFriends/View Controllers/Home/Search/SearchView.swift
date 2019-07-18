//
//  SearchView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit
import Anchorage

class SearchView: UIView {

    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movie", "TV Show", "Person"])
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()

    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .white
        addSubview(segmentedControl)
        addSubview(collectionView)

        segmentedControl.topAnchor == safeAreaLayoutGuide.topAnchor + 12
        segmentedControl.centerXAnchor == centerXAnchor
        segmentedControl.widthAnchor == 2 * widthAnchor / 3

        collectionView.topAnchor == segmentedControl.bottomAnchor + 12
        collectionView.horizontalAnchors == horizontalAnchors
        collectionView.bottomAnchor == safeAreaLayoutGuide.bottomAnchor
    }

}
