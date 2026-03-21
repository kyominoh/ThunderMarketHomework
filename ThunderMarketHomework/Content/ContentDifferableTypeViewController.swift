//
//  ContentDifferableTypeViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import UIKit

class ContentDifferableTypeViewController: UIViewController {
    typealias CellData = RandomData
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, CellData>!
    let refreshControl = UIRefreshControl()
    var items: [CellData] = []
    var page = 1
    
    let usecase = RandomUsecase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        configureDataSource()
        initSnapshot()
        getDatas()
    }
    func configureHierarchy() {
        let layout = createLayout(isGrid: true)
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<DiefferableContentCell, CellData> { cell, indexPath, cellData in
            cell.configure(data: cellData)
        }
        dataSource = UICollectionViewDiffableDataSource<Section, CellData>(collectionView: collectionView) {
            (collectionView, indexPath, cellData) -> DiefferableContentCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: cellData)
        }
    }
    
    func initSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellData>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems([])
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    func applySnapshot(randomDatas: [CellData]) {
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(randomDatas, toSection: Section.main)
        dataSource.apply(snapshot, animatingDifferences: true)
        items.append(contentsOf: randomDatas)
    }
    
    func createLayout(isGrid: Bool) -> UICollectionViewLayout {
        let columns = isGrid ? 2 : 1
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(isGrid ? 150 : 60)) // 그리드일 때 높이를 더 줌
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }   
}

extension ContentDifferableTypeViewController: ContentViewAlignChange {
    func toggleAlign(cellType: CellType) {
        let newLayout = createLayout(isGrid: cellType == .mini)
        collectionView.setCollectionViewLayout(newLayout, animated: true)
        let snapshot = dataSource.snapshot()
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ContentDifferableTypeViewController {
    func getDatas() {
        Task {
            defer {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }    
                }
            }
            do {
                let data = try await usecase.fetchData(page: page, param: .female)
                self.applySnapshot(randomDatas: data.results)
                print(data)
                if data.results.count > 0 {
                    page += 2
                }
            } catch {
                print(error)
            }
        }
    }
    
    @objc func refreshData() {
        items = []
        getDatas()
    }
}
