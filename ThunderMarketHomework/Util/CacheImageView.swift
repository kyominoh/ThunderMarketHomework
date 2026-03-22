//
//  CacheImageView.swift
//  ThunderMarketHomework
//
//  Created by 오교민 on 3/19/26.
//

import SnapKit
import UIKit

class CacheImageView: UIView {
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private var imageURL: String?
    private var retryCount = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) { 
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        addSubview(imageView)
        addSubview(activityIndicator)
        
        imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        activityIndicator.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    func loadImage(url: String) {
        imageView.image = nil
        activityIndicator.startAnimating()
        
        if let cached = MemoryCacheManager.get(forKey: url) {
            updateImage(cached)
            return
        }
        
        Task {
            if let diskImage = await DiskCacheManager.shared.load(url) {
                updateImage(diskImage)
                return
            }
            
            guard let downloadURL = URL(string: url) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: downloadURL)
                if let downloadedImage = UIImage(data: data) {
                    MemoryCacheManager.set(downloadedImage, forKey: url)
                    updateImage(downloadedImage)
                    
                    Task.detached(priority: .background) {
                        await DiskCacheManager.shared.save(downloadedImage, key: url)
                    }
                }
            } catch {
                if retryCount < 1 {
                    retryCount += 1
                    loadImage(url: url)
                }
            }
        }
    }

    private func updateImage(_ img: UIImage) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.imageView.image = img
        }
    }
}
