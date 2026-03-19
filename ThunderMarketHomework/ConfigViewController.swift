//
//  ConfigViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import SnapKit
import UIKit

final class ConfigViewController: UIViewController {
    var onButtonTap: (() -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.setTitle("add tab", for: .normal)
        button.backgroundColor = .red
        self.view.addSubview(button)
        button.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(30)
        }
    }
    @objc func buttonTapped() {
        onButtonTap?() // 정의된 동작 실행
    }
}
