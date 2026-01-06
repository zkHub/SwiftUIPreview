import Foundation

// Selection 数据模型，对应Android的Selection.kt
struct Selection: Codable {
    let id: String
    let playIndex: Int
    let cover: String?
    let skus: [Sku]
    
    // 获取封面URL
    var coverUrl: String {
        guard let cover = cover else { return "" }
        return "https://img.zthd.io/an1/acs/\(cover)"
    }
    
    // 默认初始化器
    init(id: String, playIndex: Int = 0, cover: String? = nil, skus: [Sku] = []) {
        self.id = id
        self.playIndex = playIndex
        self.cover = cover
        self.skus = skus
    }
}

// Sku 数据模型，对应Android的Sku.kt
struct Sku: Codable {
    let id: String
    let pro: Int
    let skinName: String
    let category: String
    let toningIds: [String]?
    let hidden: Bool
    
    // 默认初始化器
    init(id: String, pro: Int = 0, skinName: String, category: String, toningIds: [String]? = nil, hidden: Bool = false) {
        self.id = id
        self.pro = pro
        self.skinName = skinName
        self.category = category
        self.toningIds = toningIds
        self.hidden = hidden
    }
}