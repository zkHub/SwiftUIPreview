import Foundation

/// Template 数据模型，对应 Android 的 Template.kt
struct Template: Codable, Equatable {
    let selections: [Selection]
    let tonings: [Toning]?
    let animations: [Animation]?
    let requireCategories: [String]?
    let initAvatar: Avatar?
    
    init(selections: [Selection] = [], tonings: [Toning]? = nil, animations: [Animation]? = nil, requireCategories: [String]? = nil, initAvatar: Avatar? = nil) {
        self.selections = selections
        self.tonings = tonings
        self.animations = animations
        self.requireCategories = requireCategories
        self.initAvatar = initAvatar
    }
}

