//
//  MemoryCacheManager.swift
//  LEZHINHomework
//
//  Created by 오교민 on 3/18/26.
//

import UIKit

public class MemoryCacheManager {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
    static func get(forKey key: String) -> UIImage? {
        return shared.object(forKey: key as NSString)
    }
    static func set(_ image: UIImage, forKey key: String) {
        shared.setObject(image, forKey: key as NSString)
    }
}
