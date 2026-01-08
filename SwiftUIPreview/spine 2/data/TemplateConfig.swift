import Foundation

/// Template 数据模型，对应 Android 的 Template.kt
struct TemplateConfig: Codable, Equatable {
    let selections: [Selection]
    let tonings: [Toning]?
    let animations: [Animation]?
    let requireCategories: [String]?
    let initAvatar: Avatar?
}

