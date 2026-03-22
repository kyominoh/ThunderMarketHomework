//
//  ViewController+Rx.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/21/26.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension Reactive where Base: UIViewController {
    var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad)).map { _ in }
        return ControlEvent(events: source)
    }
}
