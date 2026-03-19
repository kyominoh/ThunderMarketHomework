//
//  DelegateContentCell.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import Foundation
import SnapKit
import UIKit

public enum CellType {
    case full
    case mini
}

class DelegateContentCell: UICollectionViewCell {
    var cellType: CellType = .full
    @IBOutlet weak var img: CacheImageView!
    @IBOutlet weak var name: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.img.snp.makeConstraints { $0.edges.equalToSuperview() }
        self.name.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.greaterThanOrEqualTo(30)
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
