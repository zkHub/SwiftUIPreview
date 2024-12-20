//
//  UIColorExt.swift
//  Avatar
//
//  Created by perol on 2022/7/26.
//

import Foundation
import UIKit

extension UIColor {
    // 通过 Hex 字符串生成 UIColor
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // 确保字符串以 '#' 开头，并且移除它
        if hexString.hasPrefix("#") {
            hexString.remove(at: hexString.startIndex)
        }
        
        // 确保字符串长度为 6 或 8（带 Alpha 通道）
        guard hexString.count == 6 || hexString.count == 8 else {
            self.init(white: 0, alpha: 0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgbValue)
        
        if hexString.count == 6 {
            // 没有 Alpha 通道，默认为 1.0
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: 1.0
            )
        } else {
            // 包含 Alpha 通道
            self.init(
                red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
                green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
                blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
                alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
            )
        }
    }

    convenience init(hexRGB: String, alpha: CGFloat = 1) {
        let chars = Array(hexRGB.dropFirst())
        self.init(red: .init(strtoul(String(chars[0 ... 1]), nil, 16)) / 255,
                  green: .init(strtoul(String(chars[2 ... 3]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[4 ... 5]), nil, 16)) / 255,
                  alpha: alpha)
    }
    
    convenience init(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
}
