import Foundation

// Toning 相关数据模型，对应Android的Toning.kt
typealias ToningColor = Color

// Toning 染色方案
struct Toning: Codable {
    let id: String
    let name: String?
    let pro: Int
    let colors: [ColorSet]
    
    // 默认初始化器
    init(id: String, name: String? = nil, pro: Int = 0, colors: [ColorSet] = []) {
        self.id = id
        self.name = name
        self.pro = pro
        self.colors = colors
    }
}

// ColorSet 颜色集
struct ColorSet: Codable {
    let id: String
    let colors: [Color]
    
    // 默认初始化器
    init(id: String, colors: [Color] = []) {
        self.id = id
        self.colors = colors
    }
}

// Color 颜色
struct Color: Codable {
    let color: String
    let offset: Float
    
    // 默认初始化器
    init(color: String, offset: Float) {
        self.color = color
        self.offset = offset
    }
}