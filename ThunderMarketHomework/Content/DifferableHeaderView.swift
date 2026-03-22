//
//  DifferableHeaderView.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/22/26.
//

import UIKit
import SnapKit

public class DifferableHeaderView: UICollectionReusableView {
    let segment = UISegmentedControl(
        items: RandomUserParam.allCases.map { $0.rawValue.capitalized }
    )
    var onSegmentChanged: ((Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        addSubview(segment)
        segment.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) { fatalError() }

    @objc func segmentChanged() {
        onSegmentChanged?(segment.selectedSegmentIndex)
    }
}
