//
//  ColorExtention.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/29.
//

import UIKit
import SwiftUI


extension Color {
    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        let uiColor = UIColor(self)
        return uiColor.getRGB()
    }
    
    func toHex() -> String? {
        let uiColor = UIColor(self)
        return uiColor.toHex()
    }
}


extension UIColor {
    
    func getRGB() -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        if let rgba = getRGBA() {
            return (red: rgba.red, green: rgba.green, blue: rgba.blue)
        } else {
            return nil
        }
    }
    
    func getRGBA() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil // 无法获取 RGB 值，可能是使用了某些颜色空间，如模式颜色
        }
    }
    
    func getRGB255() -> (red: Int, green: Int, blue: Int)? {
        guard let components = self.getRGB() else { return nil }
        return (red: Int(components.red * 255), green: Int(components.green * 255), blue: Int(components.blue * 255))
    }
    
    // 获取 UIColor 的 16 进制 HEX 值
    func toHex() -> String? {
        guard let rgba = getRGBA() else {
            return nil
        }
        
        let r = Int(rgba.red * 255)
        let g = Int(rgba.green * 255)
        let b = Int(rgba.blue * 255)
        let a = Int(rgba.alpha * 255)
        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
    
}
