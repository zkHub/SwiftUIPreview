//
//  GradientLabel.swift
//  Avatar
//
//  Created by zk on 2024/12/25.
//

import SwiftUI

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
        let adjustedSize = CGSize(width: size.width + uiView.strokeWidth, height: size.height)
        DispatchQueue.main.async {
            self.size = adjustedSize // 更新大小
        }
    }
}

struct AttributedText: View {
    @Binding var text: String
    var start: CGPoint = CGPointMake(0, 0.5)
    var end: CGPoint = CGPointMake(1, 0.5)
    var font: UIFont = UIFont.PoppinsLatinBold(size: 12)
    var colors: [UIColor] = [.black]
    var strokeWidth: CGFloat = 0
    var strokeColor: UIColor = .white
    @State var maxSize: CGSize = .zero

    @State private var size: CGSize = .zero

    var body: some View {
        AttributedTextContent(text: $text, size: $size, start: start, end: end, font: font, colors: colors, strokeWidth: strokeWidth, strokeColor: strokeColor, maxSize: maxSize)
            .frame(width: size.width, height: size.height)
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
    var maxSize: CGSize = .zero

    func makeUIView(context: Context) -> GradientLabel {
        let label = GradientLabel(frame: CGRect(origin: .zero, size: maxSize))
        label.font = font
        label.text = text
        label.textAlignment = .center
        label.start = start
        label.end = end
        label.colors = colors
        label.strokeWidth = strokeWidth
        label.strokeColor = strokeColor
        label.numberOfLines = 1
        label.backgroundColor = .red
        label.clipsToBounds = false // 避免裁剪描边
        return label
    }
    
    func updateUIView(_ uiView: GradientLabel, context: Context) {
//        uiView.text = text
//        if maxSize != .zero {
//            DispatchQueue.main.async {
//                uiView.frame = CGRect(origin: .zero, size: maxSize)
//                self.size = maxSize
//            }
//            return
//        }
//        let size = uiView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
//        let adjustedSize = CGSize(width: size.width + uiView.strokeWidth, height: size.height)
//        DispatchQueue.main.async {
//            self.size = adjustedSize // 更新大小
//        }
    }
}


class GradientLabel: UILabel {
    var start: CGPoint = CGPointMake(0, 0.5)
    var end: CGPoint = CGPointMake(1, 0.5)
    var colors: [UIColor] = [.black]
    var strokeWidth: CGFloat = 0
    var strokeColor: UIColor = .white
    
    override public func drawText(in rect: CGRect) {
        
        guard let _ = text, let currentContext = UIGraphicsGetCurrentContext() else {
            super.drawText(in: rect)
            return
        }
        
        if strokeWidth > 0 {
            self.textColor = strokeColor
            currentContext.setLineWidth(strokeWidth)
            currentContext.setLineJoin(.round)
            currentContext.setTextDrawingMode(.stroke)
            super.drawText(in: rect)
        }
        
        if colors.count <= 1 {
            currentContext.setTextDrawingMode(.fill)
            self.textColor = colors.first
            super.drawText(in: rect)
            return
        }
        
        let shadowOffset = self.shadowOffset
        currentContext.setTextDrawingMode(.fill)
        if let gradientColor = drawGradientColor(in: rect, colors: colors.map({$0.cgColor})) {
            self.textColor = gradientColor
        }
        self.shadowOffset = CGSize(width: 0, height: 0)
        super.drawText(in: rect)
        
        self.shadowOffset = shadowOffset
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
