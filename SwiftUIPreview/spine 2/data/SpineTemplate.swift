import Foundation
import BetterCodable


struct SpineTemplate: Codable, Equatable {
    let selections: [SpineSelection]
    let tonings: [SpineToning]?
    let animations: [SpineAnimation]?
    let requireCategories: [String]?
    let initAvatar: SpineAvatar?
}


struct SpineSelection: Codable, Equatable {
    let id: String
    let playIndex: Int
    let name: String?
    let cover: String?
    let skus: [SpineSku]
    
    var coverUrl: String {
        guard let cover = cover else { return "" }
        return "https://img.zthd.io/an1/acs/\(cover)"
    }
    
}


struct SpineSku: Codable, Equatable {
    let id: String
    let pro: Int
    let skinName: String
    let category: String
    let toningIds: [String]?
    let hidden: Bool?
}


struct SpineToning: Codable, Equatable {
    let id: String
    let name: String?
    let pro: Int
    let colors: [SpineColor]
}


struct SpineColor: Codable, Equatable {
    let id: String
    let light: String  // 亮色 (#hexcode)
    let dark: String    // 暗色 (#hexcode)
}


struct SpineAvatar: Codable, Equatable {
    var version: Int64 = 1
    var skus: [String] = []
    var animation: String?
    @DefaultEmptyDictionary var tonings: [String: String] = [:] // toningId: colorId
}


struct SpineAnimation: Codable, Equatable {
    let id: String
    let name: String?
    let pro: Int?
    let loop: Bool?
}
