import Foundation
import Spine
import SpineCppLite
import UIKit

/// Spine 录制器，对应 Android 的 SpineRecorder.kt
class SpineRecorder {
    private let drawable: SkeletonDrawableWrapper
    
    init(drawable: SkeletonDrawableWrapper) {
        self.drawable = drawable
    }
    
    /// 录制 GIF，对应 Android 的 recordGif
    func recordGif(
        animationName: String,
        width: Int = 512,
        height: Int = 512,
        fps: Int = 30,
        output: URL
    ) async throws {
        guard let animation = drawable.skeletonData.findAnimation(name: animationName) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到动画: \(animationName)"])
        }
        
        let duration = animation.duration
        let frameCount = max(2, Int(duration * Float(fps)))
        let delta = 1.0 / Float(fps)
        
        // 获取 skeleton 实例
        let skeleton = drawable.skeleton
        
        // 收集所有帧
        var frames: [UIImage] = []
        
        // 在主线程批量完成所有帧的渲染，尽量减少对显示动画的影响时间
        try await MainActor.run {
            // 渲染每一帧
            for frameIndex in 0..<frameCount {
                // 重置 skeleton 到初始姿态（每帧都重置，确保状态一致）
                skeleton.setToSetupPose()
                
                // 计算当前应该渲染的动画时间（循环播放）
                let currentTime = Float(frameIndex) * delta
                let animationTime = currentTime.truncatingRemainder(dividingBy: duration)
                
                // 临时设置动画并应用到特定时间
                // 注意：这会短暂影响显示的动画，但我们快速完成所有帧后立即恢复
                drawable.animationState.setAnimation(trackIndex: 0, animation: animation, loop: false)
                
                // 更新到目标时间点
                // 使用小步长更新，确保动画正确应用
                var accumulatedTime: Float = 0
                let stepSize: Float = 0.016 // 约 60fps 的步长
                while accumulatedTime < animationTime {
                    let step = min(stepSize, animationTime - accumulatedTime)
                    drawable.animationState.update(delta: step)
                    accumulatedTime += step
                }
                
                drawable.animationState.apply(skeleton: skeleton)
                
                // 更新骨架变换
                skeleton.update(delta: 0)
                skeleton.updateWorldTransform(physics: SPINE_PHYSICS_UPDATE)
                
                // 渲染 skeleton 为 UIImage
                // 使用透明背景，避免背景出现在 GIF 中
                if let cgImage = try drawable.renderToImage(
                    size: CGSize(width: width, height: height),
                    boundsProvider: RawBounds(x: -256, y: -512, width: 512, height: 512),
                    backgroundColor: .clear, // 使用透明背景
                    scaleFactor: 1.0
                ) {
                    frames.append(UIImage(cgImage: cgImage))
                }
            }
            
            // 所有帧渲染完成后，立即恢复显示的动画
            // 恢复默认的 idle 动画
            if let idleAnimation = drawable.skeletonData.findAnimation(name: "idle_default") {
                drawable.animationState.setAnimation(trackIndex: 0, animation: idleAnimation, loop: true)
            }
        }
        
        // 将 frames 编码为 GIF
        try encodeFramesToGif(frames: frames, output: output, delay: 1000 / fps)
    }
    
    /// 将帧编码为 GIF
    private func encodeFramesToGif(frames: [UIImage], output: URL, delay: Int) throws {
        guard !frames.isEmpty else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有可编码的帧"])
        }
        
        // 使用 ImageIO 创建 GIF
        guard let destination = CGImageDestinationCreateWithURL(output as CFURL, "com.compuserve.gif" as CFString, frames.count, nil) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建 GIF 目标"])
        }
        
        // 设置全局 GIF 属性（无限循环）
        let globalGifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0 // 无限循环
            ]
        ]
        CGImageDestinationSetProperties(destination, globalGifProperties as CFDictionary)
        
        // 设置每帧的延迟时间
        let delayTime = Double(delay) / 1000.0
        
        // 添加每一帧
        for frame in frames {
            guard let cgImage = frame.cgImage else { continue }
            
            let frameProperties: [String: Any] = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFDelayTime as String: delayTime
                ]
            ]
            
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        }
        
        // 完成编码
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "GIF 编码失败"])
        }
    }
}

