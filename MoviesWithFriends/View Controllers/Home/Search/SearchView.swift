//
//  SearchView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

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

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(2/3.0)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

}
