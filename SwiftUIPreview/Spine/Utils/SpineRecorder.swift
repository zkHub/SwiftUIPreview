import Foundation
import UIKit
import ImageIO

// SpineRecorder 工具类，对应Android的SpineRecorder.kt
class SpineRecorder {
    private let skeletonDrawable: SkeletonDrawable
    private let framesPerSecond: Int = 24
    
    // 初始化器
    init(_ skeletonDrawable: SkeletonDrawable) {
        self.skeletonDrawable = skeletonDrawable
    }
    
    // 录制GIF动画
    func recordGif(animationName: String, output: URL) throws {
        // 创建GIF写入器
        guard let destination = CGImageDestinationCreateWithURL(output as CFURL, kUTTypeGIF, 0, nil) else {
            throw NSError(domain: "SpineRecorder", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create GIF destination"])
        }
        
        // 设置GIF属性
        let gifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0, // 无限循环
                kCGImagePropertyGIFDelayTime as String: 1.0 / Double(framesPerSecond) // 帧率
            ]
        ]
        
        // 查找要录制的动画
        guard let animation = skeletonDrawable.skeletonData.findAnimation(animationName) else {
            throw NSError(domain: "SpineRecorder", code: 1, userInfo: [NSLocalizedDescriptionKey: "Animation not found: \(animationName)"])
        }
        
        // 计算录制时长（秒）
        let duration: Double = 2.0
        let totalFrames = Int(duration * Double(framesPerSecond))
        
        // 录制每一帧
        for frame in 0..<totalFrames {
            // 计算当前时间
            let time = Double(frame) / Double(framesPerSecond)
            
            // 更新骨骼动画
            skeletonDrawable.animationState.setAnimation(0, animation, false)
            skeletonDrawable.animationState.update(time)
            skeletonDrawable.skeleton.updateWorldTransform(Skeleton.Physics.update)
            
            // 渲染当前帧
            let renderer = SkeletonRenderer()
            let frameImage = renderer.renderToImage(width: 512, height: 512, backgroundColor: .clear, skeleton: skeletonDrawable.skeleton)
            
            // 添加帧到GIF
            guard let cgImage = frameImage.cgImage else { continue }
            CGImageDestinationAddImage(destination, cgImage, gifProperties as CFDictionary)
        }
        
        // 完成GIF写入
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "SpineRecorder", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to finalize GIF"])
        }
    }
    
    // 录制单个帧
    func captureFrame() -> UIImage {
        let renderer = SkeletonRenderer()
        return renderer.renderToImage(width: 512, height: 512, backgroundColor: .clear, skeleton: skeletonDrawable.skeleton)
    }
}