import Foundation

// Avatar 数据模型，对应Android的Avatar.kt
typealias SpineAvatar = Avatar

struct Avatar: Codable {
    let version: Int64
    let skus: [String]
    let tonings: [String: String] // toningId: colorId
    let animation: String?
    
    // 默认初始化器
    init(version: Int64 = 1, skus: [String] = [], tonings: [String: String] = [:], animation: String? = nil) {
        self.version = version
        self.skus = skus
        self.tonings = tonings
        self.animation = animation
    }
}