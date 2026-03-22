//
//  CacheManager.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

import Foundation
import UIKit

struct DiskCacheManager {
    static let shared = DiskCacheManager()
    let fileManager = FileManager.default
    var cacheDirectory: URL {
        fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ImageCache")
    }
    init() {
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func save(_ image: UIImage, key: String) {
        let fileURL = cacheDirectory.appendingPathComponent(key.safeFileName)
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        try? data.write(to: fileURL)
    }
    
    func load(_ key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(key.safeFileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
}

extension String {
    var safeFileName: String {
        String(self.hashValue)
    }
}
