//
//  ContentZoomViewController.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/22/26.
//

import Foundation
import UIKit
import SnapKit

class ContentZoomViewController: UIViewController {
    let data: RandomData
    let scrollView = UIScrollView()
    let imageView = UIImageView()

    init(data: RandomData) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadImage()
    }

    func setupUI() {
        view.backgroundColor = .black

        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 2.0
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.scrollView.bouncesZoom = true
        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }

        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.scrollView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { [weak self] in
            guard let self else { return }
            $0.edges.equalTo(self.scrollView.contentLayoutGuide)
            $0.size.equalTo(self.scrollView.frameLayoutGuide)
        }

        let closeButton2 = UIButton(type: .system)
        var closeConfig = UIButton.Configuration.plain()
        closeConfig.image = UIImage(systemName: "xmark.circle.fill")
        closeConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28)
        closeButton2.configuration = closeConfig
        closeButton2.tintColor = .white
        closeButton2.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        self.view.addSubview(closeButton2)
        closeButton2.snp.makeConstraints { [weak self] in
            guard let self else { return }
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        let scaleUPButton = UIButton(type: .system)
        var plusConfig = UIButton.Configuration.plain()
        plusConfig.image = UIImage(systemName: "plus.square")
        plusConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28)
        scaleUPButton.configuration = plusConfig
        scaleUPButton.tintColor = .white
        scaleUPButton.addTarget(self, action: #selector(didTapZoomIn), for: .touchUpInside)
        
        let scaleMinusButton = UIButton(type: .system)
        var minusCOnfig = UIButton.Configuration.plain()
        minusCOnfig.image = UIImage(systemName: "minus.square")
        minusCOnfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28)
        scaleMinusButton.configuration = minusCOnfig
        scaleMinusButton.tintColor = .white
        scaleMinusButton.addTarget(self, action: #selector(didTapZoomOut), for: .touchUpInside)
        let buttonStackView = UIStackView(arrangedSubviews: [scaleUPButton, scaleMinusButton])
        buttonStackView.axis = .horizontal
        self.view.addSubview(buttonStackView)
        buttonStackView.snp.makeConstraints { [weak self] in
            guard let self else { return }
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(10)
        }

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        self.scrollView.addGestureRecognizer(singleTap)
        self.scrollView.addGestureRecognizer(doubleTap)
    }

    func loadImage() {
        let urlString = self.data.picture.large
        if let cached = MemoryCacheManager.get(forKey: urlString) {
            self.imageView.image = cached
            return
        }

        guard let url = URL(string: urlString) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    MemoryCacheManager.set(image, forKey: urlString)
                    await MainActor.run { self.imageView.image = image }
                }
            } catch {}
        }
    }

    @objc func didTapClose() {
        self.dismiss(animated: true)
    }
    @objc func didTapZoomIn() {
        self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
    }
    @objc func didTapZoomOut() {
        self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
    }

    @objc func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if self.scrollView.zoomScale > self.scrollView.minimumZoomScale {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            let point = sender.location(in: self.imageView)
            let zoomRect = CGRect(
                x: point.x - 50,
                y: point.y - 50,
                width: 100,
                height: 100
            )
            self.scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}

extension ContentZoomViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) / 2, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) / 2, 0)
        self.imageView.center = CGPoint(
            x: scrollView.contentSize.width / 2 + offsetX,
            y: scrollView.contentSize.height / 2 + offsetY
        )
    }
}
