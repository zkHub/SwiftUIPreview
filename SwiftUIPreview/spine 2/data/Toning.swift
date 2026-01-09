import Foundation

/// Toning 数据模型，对应 Android 的 Toning.kt
struct Toning: Codable, Equatable {
    let id: String
    let name: String?
    let pro: Int
    let colors: [ColorSet]
}

/// ColorSet 数据模型，对应 Android 的 ColorSet.kt
struct ColorSet: Codable, Equatable {
    let id: String
    let light: String  // 亮色 (#hexcode)
    let dark: String    // 暗色 (#hexcode)
}

/// Color 数据模型，对应 Android 的 Color.kt
struct ToningColor: Codable, Equatable {
    let color: String
    let offset: Float
}


/// ToningSet 数据模型，对应 Android 的 ToningSet.kt
struct ToningSet: Codable, Equatable {
    let sku: Sku
    let tonings: [Toning]
}

