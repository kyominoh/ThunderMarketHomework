//
//  ContentDelegateTypeViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import SnapKit
import UIKit
import RxSwift
import RxCocoa

class ContentDelegateTypeViewController: UIViewController {
    @IBOutlet weak var collectionview: UICollectionView!
    let refreshControl = UIRefreshControl()
    var items: [RandomData] = []
    var cellType: CellType = .full
    var contentDataSource: ContentViewDataSource?
    var isLoading = false
    var isEnd = false
    let requestRelay = BehaviorRelay<(page: Int, param: RandomUserParam)>(value: (page: 1, param: RandomUserParam.male))
    let resultSubject = PublishSubject<[RandomData]>()
    let segmentSubject = PublishSubject<Int>()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureHierarchy()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let rootVC = parent?.parent as? ViewController {
            toggleAlign(cellType: rootVC.cellType)
        }
    }

    private func configureHierarchy() {
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
        }
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        collectionview.refreshControl = refreshControl
        collectionview.prefetchDataSource = self
    }
    
    private func bind() {
        self.refreshControl.rx.controlEvent(.valueChanged)
            .take(until: self.rx.deallocated)
            .withUnretained(self)
            .compactMap { owner , _ in
                owner.isEnd = false
                owner.items.removeAll()
                var param = owner.requestRelay.value 
                param.page = 1
                return param 
            }
            .bind(to: self.requestRelay)
            .disposed(by: self.disposeBag)
        self.segmentSubject
            .distinctUntilChanged()
            .take(until: self.rx.deallocated)
            .withUnretained(self)
            .compactMap { owner, index in
                owner.isEnd = false
                owner.items.removeAll()
                let param = RandomUserParam.allCases[index]
                var newParam = owner.requestRelay.value
                newParam.page = 1
                newParam.param = param
                return newParam
            }
            .bind(to: self.requestRelay)
            .disposed(by: disposeBag)
        
        self.requestRelay
            .take(until: self.rx.deallocated)
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .filter { _ in !self.isEnd }
            .withUnretained(self)
            .compactMap { owner, params in
                if !owner.isLoading {
                    owner.isLoading = true
                }
                if !owner.refreshControl.isRefreshing {
                    owner.refreshControl.beginRefreshing()
                }
                owner.requestData(params: params)
            }
            .subscribe()
            .disposed(by: self.disposeBag)
        
        self.resultSubject
            .take(until: self.rx.deallocated)
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { [weak self] newItems in
                guard let self else { return }
                let filtered = newItems.filter { !self.items.contains($0) }
                guard !filtered.isEmpty else { 
                    self.collectionview.refreshControl?.endRefreshing()
                    self.isLoading = false
                    self.isEnd = true
                    return 
                }
                if self.requestRelay.value.page == 1 {
                    self.items.append(contentsOf: filtered)
                    self.collectionview.reloadData()
                } else {
                    let startIndex = self.items.count
                    let currentCount = self.collectionview.numberOfItems(inSection: 0)
                    self.items.append(contentsOf: filtered)
                    if currentCount == startIndex {
                        let indexPaths = (0..<filtered.count).map { i in
                            IndexPath(item: startIndex + i, section: 0)
                        }
                        self.collectionview.insertItems(at: indexPaths)
                    } else {
                        self.collectionview.reloadData()
                    }
                }
                self.collectionview.refreshControl?.endRefreshing()
                self.isLoading = false
                self.isEnd = filtered.count == 0
            }
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func requestData(params: (page: Int, param: RandomUserParam)?) {
        guard let source = self.contentDataSource,
                let page = params?.page,
                let param = params?.param else { return }
        Task.detached { [weak self] in
            guard let self else { return }
            do {
                let response = try await source.getData(page: page, param: param)
                await self.resultSubject.onNext(response.results)
                print(response.results.first)
            } catch {
                print(error)
            }
        }
    }
}

extension ContentDelegateTypeViewController: ContentViewAlignChange {
    func toggleAlign(cellType: CellType) {
        self.cellType = cellType
        var space = 0.0
        if cellType == .mini { 
            space = 10
        }
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = space
            layout.minimumLineSpacing = space
            layout.invalidateLayout()
        }
        self.collectionview.reloadData()
    }
}

extension ContentDelegateTypeViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let lastIndexPath = indexPaths.last else { return }
        print("\(lastIndexPath.row), isLoding:\(isLoading), isEnd:\(isEnd)")
        if lastIndexPath.row >= items.count - 5  && !self.isEnd && !self.isLoading {
            self.isLoading = true
            var param = self.requestRelay.value
            param.page += 1
            self.requestRelay.accept(param)
        }
    }
}

extension ContentDelegateTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < items.count else { return }
        let data = items[indexPath.row]
        let vc = ContentZoomViewController(data: data)
        present(vc, animated: true)
    }
}

extension ContentDelegateTypeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DelegateHeaderView", for: indexPath) as? DelegateHeaderView else {
            return UICollectionReusableView()
        }
        header.segment.rx.selectedSegmentIndex
            .distinctUntilChanged()
            .bind(to: self.segmentSubject)
            .disposed(by: header.disposeBag) 
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "DelegateContentCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? DelegateContentCell else { return UICollectionViewCell() }
        if indexPath.row < self.items.count {
            let data = self.items[indexPath.row]
            cell.name.text = "[\(data.name.title)] \(data.name.first)"
            cell.img.loadImage(url: data.picture.thumbnail)
            cell.desc.text = data.location.city
            cell.email.text = data.email
        }
        cell.cellType = self.cellType
        return cell
    }
}
extension ContentDelegateTypeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        switch cellType {
        case .full:
            let cellWidth = width   
            return CGSize(width: cellWidth, height: 120)

        case .mini:
            let spacing: CGFloat = 10
            let cellWidth = (width - spacing) / 2
            return CGSize(width: cellWidth, height: cellWidth + 80)
        }
    }
}
