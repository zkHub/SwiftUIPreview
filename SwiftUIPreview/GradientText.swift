//
//  GradientLabel.swift
//  Avatar
//
//  Created by zk on 2024/12/25.
//

import SwiftUI
import UIKit

struct GradientText: View {
    @State var label: GradientLabel
    @State var size: CGSize = .zero
    var body: some View {
        GradientLabelContent(label: $label, size: $size)
            .frame(width: size.width, height: size.height)
    }
}

struct GradientLabelContent: UIViewRepresentable {
    @Binding var label: GradientLabel
    @Binding var size: CGSize
    
    func makeUIView(context: Context) -> GradientLabel {
        label.clipsToBounds = false // 避免裁剪描边
        return label
    }
    
    func updateUIView(_ uiView: GradientLabel, context: Context) {
        let size = uiView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        let adjustedSize = CGSize(width: size.width + uiView.strokeOutset, height: size.height + uiView.strokeOutset)
        DispatchQueue.main.async {
            self.size = adjustedSize // 更新大小
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        AttributedText(
            text: .constant("单行自动缩放超长文字超chang长唱大幅度反大C"),
            font: .PoppinsLatin(size: 15),
            colors: [UIColor.white],
            strokeWidth: 10,
            strokeColor: UIColor.red,
            maxWidth: 200,
            minimumScaleFactor: 0.2
        )
        .background(Color.black.opacity(0.3))

        AttributedText(
            text: .constant("AttributedTextAttributedTextAttributedText"),
            font: .PoppinsLatin(size: 15),
            colors: [UIColor.white],
            strokeWidth: 10,
            strokeColor: UIColor.red,
            maxWidth: 200,
            truncate: true
        )
        .background(Color.black.opacity(0.3))
        
        AttributedText(
            text: .constant("AttributedTextAttributedTextAttributedText"),
            font: .PoppinsLatin(size: 15),
            colors: [UIColor.white],
            strokeWidth: 10,
            strokeColor: UIColor.red,
            maxWidth: 100,
            truncate: false
        )
        .background(Color.black.opacity(0.3))
        
    }
    .padding()
}


struct AttributedText: View {
    @Binding var text: String
    @State var size: CGSize = .zero
    var start: CGPoint = CGPointMake(0, 0.5)
    var end: CGPoint = CGPointMake(1, 0.5)
    var font: UIFont = UIFont.PoppinsLatinBold(size: 12)
    var colors: [UIColor] = [.black]
    var strokeWidth: CGFloat = 0
    var strokeColor: UIColor = .white
    var maxWidth: CGFloat = .greatestFiniteMagnitude
    var truncate: Bool = false // 是否启用文本截断
    var minimumScaleFactor: CGFloat = 0 // 单行自动缩放，0 表示不缩放

    var body: some View {
        AttributedTextContent(
            text: $text,
            size: $size,
            start: start,
            end: end,
            font: font,
            colors: colors,
            strokeWidth: strokeWidth,
            strokeColor: strokeColor,
            maxWidth: maxWidth,
            truncate: truncate,
            minimumScaleFactor: minimumScaleFactor
        )
        .frame(
            width: size.width > 0 ? size.width : nil,
            height: size.height > 0 ? size.height : nil
        )
    }
}

struct AttributedTextContent: UIViewRepresentable {
    @Binding var text: String
    @Binding var size: CGSize
    var start: CGPoint = CGPointMake(0, 0.5)
    var end: CGPoint = CGPointMake(1, 0.5)
    var font: UIFont = UIFont.PoppinsLatinBold(size: 12)
    var colors: [UIColor] = [.black]
    var strokeWidth: CGFloat = 0
    var strokeColor: UIColor = .white
    var maxWidth: CGFloat = .greatestFiniteMagnitude
    var truncate: Bool = false // 是否启用文本截断
    var minimumScaleFactor: CGFloat = 0 // 单行自动缩放，0 表示不缩放

    func makeUIView(context: Context) -> GradientLabel {
        let label = GradientLabel()
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.clipsToBounds = false // 避免裁剪描边
        applyConfiguration(to: label)
        return label
    }

    func updateUIView(_ uiView: GradientLabel, context: Context) {
        applyConfiguration(to: uiView)
        // 仅描边/颜色等变化而 text 不变时，UILabel 不会自动重绘自定义 drawText
        uiView.setNeedsDisplay()
        let adjustedSize = measureSize(for: uiView)
        if size != adjustedSize {
            DispatchQueue.main.async {
                size = adjustedSize
            }
        }
    }

    /// 应用文字样式与排版模式
    private func applyConfiguration(to label: GradientLabel) {
        label.baseFont = font
        label.font = font
        label.text = text
        label.start = start
        label.end = end
        label.colors = colors
        label.strokeWidth = strokeWidth
        label.strokeColor = strokeColor

        let contentMaxWidth = max(0, maxWidth - label.strokeOutset)
        label.preferredMaxLayoutWidth = contentMaxWidth

        if minimumScaleFactor > 0 {
            // 单行自动缩放：不截断，超出 maxWidth 时缩小字体
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = minimumScaleFactor
            label.lineBreakMode = .byClipping
        } else if truncate {
            label.numberOfLines = 1
            label.adjustsFontSizeToFitWidth = false
            label.lineBreakMode = .byTruncatingTail
        } else {
            label.numberOfLines = 0
            label.adjustsFontSizeToFitWidth = false
        }
    }

    /// 测量布局尺寸
    private func measureSize(for label: GradientLabel) -> CGSize {
        let stroke = label.strokeOutset
        let fitWidth = max(0, maxWidth - stroke)

        if minimumScaleFactor > 0 {
            // 先测量自然宽度，未超 maxWidth 则按实际宽度，超出则约束宽度并自动缩放字体
            let naturalMeasured = label.sizeThatFits(
                CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
            )
            let naturalWidth = naturalMeasured.width + stroke

            if naturalWidth <= maxWidth {
                label.bounds.size.width = naturalMeasured.width
                return CGSize(width: naturalWidth, height: naturalMeasured.height + stroke)
            }

            label.bounds.size.width = fitWidth
            label.setNeedsLayout()
            label.layoutIfNeeded()
            let measured = label.sizeThatFits(
                CGSize(width: fitWidth, height: .greatestFiniteMagnitude)
            )
            return CGSize(width: maxWidth, height: measured.height + stroke)
        }

        let measured = label.sizeThatFits(
            CGSize(width: fitWidth, height: .greatestFiniteMagnitude)
        )
        return CGSize(
            width: min(measured.width + stroke, maxWidth),
            height: measured.height + stroke
        )
    }
}


class GradientLabel: UILabel {
    var start: CGPoint = CGPointMake(0, 0.5)
    var end: CGPoint = CGPointMake(1, 0.5)
    var colors: [UIColor] = [.black]
    var strokeWidth: CGFloat = 0
    var strokeColor: UIColor = .white
    /// 原始字号，自动缩放前从此恢复，避免多次 update 叠乘缩小
    var baseFont: UIFont?
    /// 描边向文字外侧扩展 strokeWidth / 2，左右/上下合计需要预留 strokeWidth。
    var strokeOutset: CGFloat {
        strokeWidth > 0 ? ceil(strokeWidth) : 0
    }
    
    override public func drawText(in rect: CGRect) {
        
        guard let _ = text, let currentContext = UIGraphicsGetCurrentContext() else {
            super.drawText(in: rect)
            return
        }
        let drawingRect = textDrawingRect(in: rect)
        
        if strokeWidth > 0 {
            self.textColor = strokeColor
            currentContext.setLineWidth(strokeWidth)
            currentContext.setLineJoin(.round)
            currentContext.setTextDrawingMode(.stroke)
            super.drawText(in: drawingRect)
        }
        
        if colors.count <= 1 {
            currentContext.setTextDrawingMode(.fill)
            self.textColor = colors.first
            super.drawText(in: drawingRect)
            return
        }
        
        let shadowOffset = self.shadowOffset
        currentContext.setTextDrawingMode(.fill)
        if let gradientColor = drawGradientColor(in: drawingRect, colors: colors.map({$0.cgColor})) {
            self.textColor = gradientColor
        }
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: drawingRect)
        
        self.shadowOffset = shadowOffset
    }
    
    private func textDrawingRect(in rect: CGRect) -> CGRect {
        let inset = strokeOutset / 2
        return rect.insetBy(
            dx: min(inset, rect.width / 2),
            dy: min(inset, rect.height / 2)
        )
    }
    
    
    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }
        
        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }
        
        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPointMake(start.x * size.width, start.y * size.height),
                                    end: CGPointMake(end.x * size.width, end.y * size.height),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
