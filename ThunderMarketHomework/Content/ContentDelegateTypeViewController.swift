//
//  ContentDelegateTypeViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import SnapKit
import UIKit

class ContentDelegateTypeViewController: UIViewController {
    @IBOutlet weak var collectionview: UICollectionView!
    var cellType: CellType = .full
    var items: [RandomData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = .zero
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    private func getData() {
        let usecase = RandomUsecase()
        Task {
            do {
                let data = try await usecase.fetchMaleUser()
                items.append(contentsOf: data.results)
                print(data)
                self.collectionview.reloadData()
            } catch {
                print(error)
            }
        }
    }
}

extension ContentDelegateTypeViewController {
    @IBAction func toggleAlign(_ sender: UIButton) {
        var space = 0.0
        if cellType == .full { 
            cellType = .mini
            space = 10
        } else {
            cellType = .full
        }
        if let layout = collectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = space
            layout.minimumLineSpacing = space
        }
        self.collectionview.reloadData()
    }
}

extension ContentDelegateTypeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

extension ContentDelegateTypeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = "DelegateContentCell"
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? DelegateContentCell else { return UICollectionViewCell() }
        let data = self.items[indexPath.row];
        cell.name.text = data.name.title
        cell.img.loadImage(url: data.picture.thumbnail)
        return cell
    }
}
extension ContentDelegateTypeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        switch cellType {
        case .full:
            let cellWidth = width   
            return CGSize(width: cellWidth, height: cellWidth)

        case .mini:
            let spacing: CGFloat = 10
            let cellWidth = (width - spacing) / 2
            return CGSize(width: cellWidth, height: cellWidth)
        }
    }
}
