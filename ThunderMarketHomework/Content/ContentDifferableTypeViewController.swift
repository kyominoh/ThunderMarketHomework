//
//  ContentDifferableTypeViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import UIKit
import ComposableArchitecture
import SnapKit

enum Section: Hashable, Sendable {
    case main
}

class ContentDifferableTypeViewController: UIViewController {
    typealias CellData = RandomData

    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, CellData>!
    let refreshControl = UIRefreshControl()
    var cellType: CellType = .full

    let store = Store(initialState: ContentFeature.State()) {
        ContentFeature()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHierarchy()
        self.configureDataSource()
        self.initSnapshot()
        self.bindStore()
        self.store.send(.request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let rootVC = parent?.parent as? ViewController {
            toggleAlign(cellType: rootVC.cellType)
        }
    }

    func configureHierarchy() {
        let layout = createLayout(cellType: cellType)
        self.collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.delegate = self
        self.collectionView.prefetchDataSource = self
        view.addSubview(self.collectionView)

        self.refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5
        self.collectionView.addGestureRecognizer(longPress)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let location = gesture.location(in: self.collectionView)
        guard let indexPath = self.collectionView.indexPathForItem(at: location),
              let item = self.dataSource.itemIdentifier(for: indexPath) else { return }

        let alert = UIAlertController(
            title: "\(item.name.first) \(item.name.last)",
            message: "이 항목을 삭제하시겠습니까?",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.store.send(.delete(item))
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true)
    }

    // MARK: - DataSource

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DiefferableContentCell, CellData> { [weak self] cell, _, cellData in
            guard let self else { return }
            cell.configure(data: cellData, cellType: self.cellType)
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<DifferableHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] view, _, _ in
            guard let self else { return }
            view.onSegmentChanged = { [weak self] index in
                guard let self else { return }
                let param = RandomUserParam.allCases[index]
                self.store.send(.fetchTypeChanged(param))
            }
        }

        self.dataSource = UICollectionViewDiffableDataSource<Section, CellData>(
            collectionView: self.collectionView
        ) { collectionView, indexPath, cellData -> DiefferableContentCell? in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: cellData)
        }

        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }

    func initSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections([.main])
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }

    func bindStore() {
        observe { [weak self] in
            guard let self else { return }

            var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.store.items, toSection: .main)
            self.dataSource.apply(snapshot, animatingDifferences: true)

            if !self.store.isLoading {
                self.refreshControl.endRefreshing()
            }
        }
    }

    @objc func refreshData() {
        self.store.send(.refresh)
    }

    func createLayout(cellType: CellType) -> UICollectionViewLayout {
        let screenWidth = UIScreen.main.bounds.width
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(50)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.pinToVisibleBounds = true

        switch cellType {
        case .full:
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(120)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return UICollectionViewCompositionalLayout(section: section)

        case .mini:
            let spacing: CGFloat = 10
            let cellWidth = (screenWidth - spacing) / 2
            let cellHeight = cellWidth + 80
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(cellHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(cellHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
            group.interItemSpacing = .fixed(spacing)
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = spacing
            section.boundarySupplementaryItems = [header]
            return UICollectionViewCompositionalLayout(section: section)
        }
    }
}

extension ContentDifferableTypeViewController: ContentViewAlignChange {
    func toggleAlign(cellType: CellType) {
        self.cellType = cellType
        let newLayout = self.createLayout(cellType: cellType)
        self.collectionView.setCollectionViewLayout(newLayout, animated: true)
        var snapshot = self.dataSource.snapshot()
        snapshot.reconfigureItems(snapshot.itemIdentifiers)
        self.dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ContentDifferableTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = ContentZoomViewController(data: item)
        self.present(vc, animated: true)
    }
}

extension ContentDifferableTypeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndex = indexPaths.last?.item,
              lastIndex >= self.store.items.count - 5,
              !self.store.isEnd,
              !self.store.isLoading else { return }
        self.store.send(.request)
    }
}
