import Foundation

/// Avatar 数据模型，对应 Android 的 Avatar.kt
struct Avatar: Codable, Equatable {
    var version: Int64 = 1
    var skus: [String] = []
    var tonings: [String: String]? = [:] // toningId: colorId
    var animation: String? = nil
    
}

typealias SpineAvatar = Avatar

