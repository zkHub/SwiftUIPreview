import Foundation

// ToningSet 数据模型，对应Android的ToningSet.kt
struct ToningSet: Codable {
    let sku: Sku
    let tonings: [Toning]
    
    // 默认初始化器
    init(sku: Sku, tonings: [Toning]) {
        self.sku = sku
        self.tonings = tonings
    }
}