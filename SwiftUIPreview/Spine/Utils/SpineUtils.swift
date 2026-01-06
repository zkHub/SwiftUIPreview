import Foundation
import Spine
import SpineCppLite

// SpineUtils 工具类，对应Android的SpineUtils.kt
class SpineUtils {
    // 单例实例
    static let shared = SpineUtils()
    
    // 私有初始化器
    private init() {}
    
    // 获取骨骼皮肤映射
    func getSkeletonSkins(drawable: SkeletonDrawable) -> [String: UIImage] {
        let maxWidth: CGFloat = 200
        let maxHeight: CGFloat = 200
        let minWidth: CGFloat = 80
        let minHeight: CGFloat = 80
        
        var skins: [String: UIImage] = [:]
        let skinArray = drawable.skeletonData.skins
        
        for skin in skinArray {
            let skinName = skin.name
            let skeleton = Skeleton(drawable.skeletonData)
            skeleton.setSkin(skin)
            skeleton.setToSetupPose()
            skeleton.update(0)
            skeleton.updateWorldTransform(Skeleton.Physics.update)
            
            // 计算骨骼边界
            let bounds = skeleton.getBounds()
            var width = bounds.size.x
            var height = bounds.size.y
            
            // 限制大小范围
            if width < minWidth { width = minWidth }
            if height < minHeight { height = minHeight }
            if width > maxWidth { width = maxWidth }
            if height > maxHeight { height = maxHeight }
            
            // 渲染骨骼到UIImage
            let renderer = SkeletonRenderer()
            let image = renderer.renderToImage(width: width, height: height, backgroundColor: .clear, skeleton: skeleton)
            skins[skinName] = image
        }
        
        return skins
    }
    
    // 获取SKU插槽映射
    func getSkeletonSlots(drawable: SkeletonDrawable, template: Template) -> [String: Set<String>] {
        var mapping: [String: Set<String>] = [:]
        
        for selection in template.selections {
            for sku in selection.skus {
                // 查找对应的皮肤
                guard let skin = drawable.skeletonData.findSkin(sku.skinName) else { continue }
                
                var slotNames: Set<String> = []
                
                // 获取皮肤的所有附件，并收集对应的插槽名称
                for attachment in skin.attachments {
                    let slotIndex = attachment.slotIndex
                    let slot = drawable.skeletonData.slots[slotIndex]
                    slotNames.insert(slot.name)
                }
                
                mapping[sku.id] = slotNames
            }
        }
        
        return mapping
    }
}

// 扩展Skeleton，添加获取边界的方法
extension Skeleton {
    func getBounds() -> (offset: CGPoint, size: CGSize) {
        // 计算骨骼边界
        var minX: CGFloat = .greatestFiniteMagnitude
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxX: CGFloat = -.greatestFiniteMagnitude
        var maxY: CGFloat = -.greatestFiniteMagnitude
        
        // 遍历所有插槽的边界
        for slot in slots {
            // 简化实现，实际应获取插槽附件的边界
            // 这里需要根据Spine iOS库的API调整
            let slotBounds = getSlotBounds(slot)
            minX = min(minX, slotBounds.minX)
            minY = min(minY, slotBounds.minY)
            maxX = max(maxX, slotBounds.maxX)
            maxY = max(maxY, slotBounds.maxY)
        }
        
        let offset = CGPoint(x: minX, y: minY)
        let size = CGSize(width: maxX - minX, height: maxY - minY)
        
        return (offset: offset, size: size)
    }
    
    // 获取单个插槽的边界
    private func getSlotBounds(_ slot: Slot) -> CGRect {
        // 简化实现，实际应获取插槽附件的边界
        // 这里需要根据Spine iOS库的API调整
        return CGRect(x: 0, y: 0, width: 100, height: 100)
    }
}

// 扩展SkeletonRenderer，添加渲染到UIImage的方法
extension SkeletonRenderer {
    func renderToImage(width: CGFloat, height: CGFloat, backgroundColor: UIColor, skeleton: Skeleton) -> UIImage {
        // 创建一个图形上下文
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        // 设置背景颜色
        backgroundColor.setFill()
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        
        // 渲染骨骼
        // 这里需要根据Spine iOS库的API调整
        // 示例：render(skeleton, context)
        
        // 返回生成的UIImage
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            return UIImage()
        }
        
        return image
    }
}
