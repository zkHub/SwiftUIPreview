import Foundation

// Animation 数据模型，对应Android的Animation.kt
struct Animation: Codable {
    let id: String
    let name: String?
    let pro: Int
    let loop: Bool
    
    // 默认初始化器
    init(id: String, name: String? = nil, pro: Int = 0, loop: Bool = true) {
        self.id = id
        self.name = name
        self.pro = pro
        self.loop = loop
    }
}