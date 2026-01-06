import Foundation
import Spine
import SpineCppLite
import UIKit

/// Spine 工具类，对应 Android 的 SpineUtils.kt
enum SpineUtils {
    
    /// 获取所有皮肤的缩略图，对应 Android 的 getSkeletonSkins
    @MainActor
    static func getSkeletonSkins(drawable: SkeletonDrawableWrapper) async throws -> [String: UIImage] {
        return try await MainActor.run {
            var skeletonSkins: [String: UIImage] = [:]
            for skin in drawable.skeletonData.skins {
                if skin.name == "default" { continue }
                let skeleton = drawable.skeleton
                skeleton.skin = skin
                skeleton.setToSetupPose()
                skeleton.update(delta: 0)
                skeleton.updateWorldTransform(physics: SPINE_PHYSICS_UPDATE)
                try skin.name.flatMap { skinName in
                    if let img = try drawable.renderToImage(
                        size: CGSizeMake(200, 200),
                        backgroundColor: .white,
                        scaleFactor: UIScreen.main.scale
                    ) {
                        skeletonSkins[skinName] = UIImage(cgImage: img)
                    }
                }
            }
            return skeletonSkins
        }
    }
    
    /// 获取 SKU 对应的 Slot 名称集合，对应 Android 的 getSkeletonSlots
    static func getSkeletonSlots(drawable: SkeletonDrawableWrapper, template: Template) -> [String: Set<String>] {
        var mapping: [String: Set<String>] = [:]
        
        for selection in template.selections {
            for sku in selection.skus {
                guard let skin = drawable.skeletonData.findSkin(name: sku.skinName) else { continue }
                
                var slotNames = Set<String>()
                // 遍历 skin 的 attachments 来获取 slot 名称
                // 注意：Spine iOS 的 API 可能不同，这里需要根据实际 API 调整
                
//                skin.getAttachment(slotIndex: Int32, name: <#T##String?#>)
//                skin.entries
                
                for slot in drawable.skeletonData.slots {
                    if let slotName = skin.getAttachment(slotIndex: slot.index, name: slot.name)?.name {
                        slotNames.insert(slot.name!)
                    }
                }
                
//                if let attachments = skin.attachments {
//                    for entry in attachments {
//                        if let slotIndex = entry.slotIndex,
//                           slotIndex < drawable.skeletonData.slots.count {
//                            let slot = drawable.skeletonData.slots[slotIndex]
//                            if let slotName = slot.name {
//                                slotNames.insert(slotName)
//                            }
//                        }
//                    }
//                }
                
                mapping[sku.id] = slotNames
            }
        }
        
        return mapping
    }
    
    /// 将 Skeleton 渲染为 UIImage
    private static func renderSkeletonToImage(skeleton: Skeleton, width: CGFloat, height: CGFloat) -> UIImage? {
        // 使用 Metal 渲染到纹理，然后转换为 UIImage
        // 这里需要根据 Spine iOS 的实际渲染 API 来实现
        // 暂时返回 nil，需要后续根据实际 API 完善
        return nil
    }
}

