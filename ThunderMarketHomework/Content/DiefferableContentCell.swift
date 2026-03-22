//
//  DiefferableContentCell.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import SnapKit
import UIKit

class DiefferableContentCell: UICollectionViewCell {
    let thumbnailView = CacheImageView()
    private let labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        return stack
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    private let descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 1
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        thumbnailView.clipsToBounds = true
        thumbnailView.backgroundColor = .systemGray6
        [nameLabel, descLabel, emailLabel].forEach { labelStack.addArrangedSubview($0) }
        contentView.addSubview(thumbnailView)
        contentView.addSubview(labelStack)
    }
    
    func configure(data: RandomData, cellType: CellType) {
        nameLabel.text = "[\(data.name.title)] \(data.name.first)"
        descLabel.text = data.location.city
        emailLabel.text = data.email
        thumbnailView.loadImage(url: data.picture.thumbnail)
        updateLayout(cellType: cellType)
    }
    
    func updateLayout(cellType: CellType) {
        switch cellType {
        case .full:
            thumbnailView.layer.cornerRadius = 8
            thumbnailView.snp.remakeConstraints {
                $0.leading.top.bottom.equalToSuperview()
                $0.width.equalTo(thumbnailView.snp.height)
            }
            labelStack.snp.remakeConstraints {
                $0.leading.equalTo(thumbnailView.snp.trailing).offset(12)
                $0.trailing.equalToSuperview().inset(8)
                $0.centerY.equalToSuperview()
            }

        case .mini:
            thumbnailView.layer.cornerRadius = 0
            thumbnailView.snp.remakeConstraints {
                $0.top.leading.trailing.equalToSuperview()
                $0.height.equalTo(thumbnailView.snp.width)
            }
            labelStack.snp.remakeConstraints {
                $0.top.equalTo(thumbnailView.snp.bottom).offset(6)
                $0.leading.trailing.equalToSuperview().inset(6)
                $0.bottom.lessThanOrEqualToSuperview().inset(6)
            }
        }
    }
}
