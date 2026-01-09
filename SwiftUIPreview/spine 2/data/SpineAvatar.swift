import Foundation
import BetterCodable

/// Avatar 数据模型，对应 Android 的 Avatar.kt
struct SpineAvatar: Codable, Equatable {
    var version: Int64 = 1
    var skus: [String] = []
    var animation: String?
    @DefaultEmptyDictionary var tonings: [String: String] = [:] // toningId: colorId
}


