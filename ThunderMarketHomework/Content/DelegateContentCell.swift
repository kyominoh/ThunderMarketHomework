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
    public var cellType: CellType = .full {
        didSet {
            updateLayout()
        }
    }
    
    @IBOutlet weak var img: CacheImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var email: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        img.layer.cornerRadius = 8
        img.clipsToBounds = true
        updateLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func updateLayout() {
        switch cellType {
        case .full:
            img.snp.remakeConstraints {
                $0.leading.top.bottom.equalToSuperview()
                $0.width.equalTo(img.snp.height)
            }
            name.snp.remakeConstraints {
                $0.leading.equalTo(img.snp.trailing).offset(10)
                $0.top.equalToSuperview().offset(8)
                $0.trailing.equalToSuperview().inset(8)
            }
            desc.snp.remakeConstraints {
                $0.leading.equalTo(img.snp.trailing).offset(10)
                $0.top.equalTo(name.snp.bottom).offset(4)
                $0.trailing.equalToSuperview().inset(8)
            }
            email.snp.remakeConstraints {
                $0.leading.equalTo(img.snp.trailing).offset(10)
                $0.top.equalTo(desc.snp.bottom).offset(4)
                $0.trailing.equalToSuperview().inset(8)
            }

        case .mini:
            img.snp.remakeConstraints {
                $0.leading.top.trailing.equalToSuperview()
                $0.height.equalTo(img.snp.width)
            }
            name.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(4)
                $0.top.equalTo(img.snp.bottom).offset(5)
            }
            desc.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(4)
                $0.top.equalTo(name.snp.bottom).offset(4)
            }
            email.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview().inset(4)
                $0.top.equalTo(desc.snp.bottom).offset(4)
            }
        }
    }
}
