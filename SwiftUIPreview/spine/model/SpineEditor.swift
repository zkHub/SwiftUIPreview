import Foundation
import Spine
import UIKit

/// Editor 数据模型，对应 Android 的 Editor.kt
struct SpineEditor {
    let template: SpineTemplate
    let skeletonSkins: [String: UIImage] // skinName: image
    let skuSlots: [String: Set<String>] // skuId: slotNames
}

/// ToningSet 数据模型，对应 Android 的 ToningSet.kt
struct ToningSet: Codable, Equatable {
    let sku: SpineSku
    let tonings: [SpineToning]
}
