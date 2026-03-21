//
//  DelegateHeaderView.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/21/26.
//

import Foundation
import SnapKit
import RxSwift
import UIKit

class DelegateHeaderView: UICollectionReusableView {
    @IBOutlet weak var segment: UISegmentedControl!
    var disposeBag = DisposeBag()
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
