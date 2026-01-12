import Foundation
import UIKit



/// Color 数据模型，对应 Android 的 Color.kt
struct ToningColor: Codable, Equatable {
    let color: String
    let offset: Float
}


/// 颜色采样器，对应 Android 的 ColorSampler.kt
class ColorSampler {
    private let sortedColors: [ToningColor]
    
    init(colors: [ToningColor]) {
        self.sortedColors = colors.sorted { $0.offset < $1.offset }
    }
    
    /// 采样颜色，对应 Android 的 sample 方法
    private func sample(t: Float) -> UIColor {
        guard !sortedColors.isEmpty else {
            return .white
        }
        
        let clampedT = max(0.0, min(1.0, t))
        
        guard let first = sortedColors.first, let last = sortedColors.last else {
            return .white
        }
        
        if clampedT <= first.offset {
            return hexToColor(first.color)
        }
        if clampedT >= last.offset {
            return hexToColor(last.color)
        }
        
        for i in 0..<(sortedColors.count - 1) {
            let a = sortedColors[i]
            let b = sortedColors[i + 1]
            if clampedT >= a.offset && clampedT <= b.offset {
                let span = b.offset - a.offset
                let localT = span > 0 ? (clampedT - a.offset) / span : 0.0
                return lerpColor(from: hexToColor(a.color), to: hexToColor(b.color), t: localT)
            }
        }
        
        return hexToColor(last.color)
    }
    
    /// 获取亮色，对应 Android 的 bright()
    func bright() -> UIColor {
        return sample(t: 0.8)
    }
    
    /// 获取暗色，对应 Android 的 dark()
    func dark() -> UIColor {
        return sample(t: 0.2)
    }
    
    /// 颜色插值
    private func lerpColor(from: UIColor, to: UIColor, t: Float) -> UIColor {
        var fromR: CGFloat = 0
        var fromG: CGFloat = 0
        var fromB: CGFloat = 0
        var fromA: CGFloat = 0
        from.getRed(&fromR, green: &fromG, blue: &fromB, alpha: &fromA)
        
        var toR: CGFloat = 0
        var toG: CGFloat = 0
        var toB: CGFloat = 0
        var toA: CGFloat = 0
        to.getRed(&toR, green: &toG, blue: &toB, alpha: &toA)
        
        let r = fromR + (toR - fromR) * CGFloat(t)
        let g = fromG + (toG - fromG) * CGFloat(t)
        let b = fromB + (toB - fromB) * CGFloat(t)
        let a = fromA + (toA - fromA) * CGFloat(t)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// 十六进制字符串转 UIColor
    private func hexToColor(_ hex: String) -> UIColor {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        
        let r, g, b, a: CGFloat
        switch cleaned.count {
        case 8: // RRGGBBAA
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        case 6: // RRGGBB
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x000000FF) / 255.0
            a = 1.0
        default:
            return .white
        }
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

/// UIColor 扩展，转换为 RGBA 格式（对应 Android 的 toRgba）
extension UIColor {
    func toRgba() -> UInt32 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rInt = UInt32(r * 255) << 24
        let gInt = UInt32(g * 255) << 16
        let bInt = UInt32(b * 255) << 8
        let aInt = UInt32(a * 255)
        
        return rInt | gInt | bInt | aInt
    }
}

