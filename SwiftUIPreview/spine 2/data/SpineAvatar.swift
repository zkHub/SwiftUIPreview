import Foundation

/// Avatar 数据模型，对应 Android 的 Avatar.kt
struct SpineAvatar: Codable, Equatable {
    var version: Int64 = 1
    var skus: [String] = []
    var animation: String?
    var tonings: [String: String]? = [:] // toningId: colorId
}


