//
//  SwiftUIPreviewApp.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/28.
//

import SwiftUI
import Kingfisher
import KingfisherWebP

@main
struct SwiftUIPreviewApp: App {
    
    init() {
        // WebP支持
        KingfisherManager.shared.defaultOptions += [
          .processor(WebPProcessor.default),
          .cacheSerializer(WebPSerializer.default),
//          .cacheOriginalImage
        ]
        
        // 限制图片缓存大小为当前设备最大物理内存的5%
        let defaultImageCache = KingfisherManager.shared.cache
        let totalRAM = ProcessInfo.processInfo.physicalMemory
        defaultImageCache.memoryStorage.config.totalCostLimit = Int(totalRAM / 20)
        defaultImageCache.diskStorage.config.sizeLimit = 500 * 1024 * 1024  // 500MB 磁盘缓存
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
