//
//  SearchView.swift
//  MoviesWithFriends
//
//  Created by Peter Sun on 7/16/19.
//  Copyright © 2019 Peter Sun. All rights reserved.
//

import UIKit

class SearchView: UIView {

    let blurBackgroundView: BlurBackgroundView = {
        return BlurBackgroundView()
    }()

    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Movie", "TV Show", "Person"])
        segmentedControl.tintColor = UIColor(named: "offYellow")
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)]
        segmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
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
        addSubview(blurBackgroundView)
        blurBackgroundView.addSubview(segmentedControl)
        blurBackgroundView.addSubview(collectionView)

        blurBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }

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
