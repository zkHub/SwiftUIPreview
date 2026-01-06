import Foundation

/// Animation 数据模型，对应 Android 的 Animation.kt
struct Animation: Codable, Equatable {
    let id: String
    let name: String?
    let pro: Int
    let loop: Bool
    
    init(id: String, name: String? = nil, pro: Int = 0, loop: Bool = true) {
        self.id = id
        self.name = name
        self.pro = pro
        self.loop = loop
    }
}

