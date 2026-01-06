import Foundation

/// Selection 数据模型，对应 Android 的 Selection.kt
struct Selection: Codable, Equatable {
    let id: String
    let playIndex: Int
    let cover: String?
    let skus: [Sku]
    
    var coverUrl: String {
        guard let cover = cover else { return "" }
        return "https://img.zthd.io/an1/acs/\(cover)"
    }
    
}

/// Sku 数据模型，对应 Android 的 Sku.kt
struct Sku: Codable, Equatable {
    let id: String
    let pro: Int
    let skinName: String
    let category: String
    let toningIds: [String]?

}

