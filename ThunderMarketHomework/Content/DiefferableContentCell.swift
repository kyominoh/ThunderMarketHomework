//
//  DiefferableContentCell.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import SnapKit
import UIKit

class DiefferableContentCell: UICollectionViewCell {
    let titleLabel = UILabel()
    let thumbnailView = CacheImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        // 썸네일 설정
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 8
        thumbnailView.backgroundColor = .systemGray6
        
        // 타이틀 설정
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        // 뷰 계층 구조 추가
        contentView.addSubview(thumbnailView)
        contentView.addSubview(titleLabel)
        
        thumbnailView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func configure(data: RandomData) {
        titleLabel.text = data.name.title
        thumbnailView.loadImage(url: data.picture.thumbnail)
    }
}
