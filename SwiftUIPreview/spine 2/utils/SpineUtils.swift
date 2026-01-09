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
    static func getSkeletonSlots(drawable: SkeletonDrawableWrapper, template: TemplateConfig) -> [String: Set<String>] {
        var mapping: [String: Set<String>] = [:]
        
        for selection in template.selections {
            for sku in selection.skus {
                guard let skin = drawable.skeletonData.findSkin(name: sku.skinName) else { continue }
                
                var slotNames = Set<String>()
                // 通过 skin 的 attachments 来获取 slot 名称
                for slot in drawable.skeletonData.slots {
                    if let _ = skin.getAttachment(slotIndex: slot.index, name: slot.name)?.name {
                        slotNames.insert(slot.name!)
                    }
                }
                mapping[sku.id] = slotNames
            }
        }
        
        return mapping
    }

}

