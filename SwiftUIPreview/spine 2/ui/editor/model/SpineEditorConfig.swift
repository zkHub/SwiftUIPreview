import Foundation
import Spine
import UIKit

/// Editor 数据模型，对应 Android 的 Editor.kt
struct SpineEditorConfig {
    let template: TemplateConfig
    let skeletonSkins: [String: UIImage] // skinName: image
    let skuSlots: [String: Set<String>] // skuId: slotNames
}

