import Foundation
import UIKit

// ColorSampler 工具类，对应Android的ColorSampler.kt
class ColorSampler {
    private let colors: [Color]
    
    // 初始化器
    init(_ colors: [Color]) {
        self.colors = colors
    }
    
    // 获取亮色
    func bright() -> Color {
        // 简化实现，实际应根据offset计算亮色
        // 这里返回第一个颜色作为示例
        return colors.first ?? Color(color: "#FFFFFF", offset: 0.0)
    }
    
    // 获取暗色
    func dark() -> Color {
        // 简化实现，实际应根据offset计算暗色
        // 这里返回最后一个颜色作为示例
        return colors.last ?? Color(color: "#000000", offset: 1.0)
    }
    
    // 根据偏移量获取颜色
    func color(at offset: Float) -> Color {
        // 简化实现，实际应根据offset插值计算
        // 这里返回第一个颜色作为示例
        return colors.first ?? Color(color: "#FFFFFF", offset: 0.0)
    }
}

// 扩展Color，添加颜色转换方法
extension Color {
    // 转换为UIColor
    var uiColor: UIColor {
        return UIColor(hexString: self.color)
    }
    
    // 转换为RGBA值
    func toRgba() -> (r: Float, g: Float, b: Float, a: Float) {
        let color = self.uiColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (Float(r), Float(g), Float(b), Float(a))
    }
}

// 扩展UIColor，添加十六进制字符串初始化方法
extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}