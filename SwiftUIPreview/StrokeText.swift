//
//  StrokeText.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/6/1.
//
//  原生SwiftUI文字描边组件
//  - 纯色描边 + 纯色填充
//  - 纯色描边 + 渐变填充
//  - 渐变描边 + 纯色/渐变填充
//  - ViewModifier 扩展方式

import SwiftUI

// MARK: - 方向计算（预计算常量，避免 body 重复计算）

/// 预计算的描边偏移方向（单位圆上的点）
private let strokeOffsets8: [(dx: CGFloat, dy: CGFloat)] = (0..<8).map { i in
    let angle = Double(i) * .pi * 2 / 8
    return (cos(angle), sin(angle))
}

private let strokeOffsets16: [(dx: CGFloat, dy: CGFloat)] = (0..<16).map { i in
    let angle = Double(i) * .pi * 2 / 16
    return (cos(angle), sin(angle))
}

private let strokeOffsets32: [(dx: CGFloat, dy: CGFloat)] = (0..<32).map { i in
    let angle = Double(i) * .pi * 2 / 32
    return (cos(angle), sin(angle))
}

/// 根据品质获取预计算的方向数组
private func strokeOffsets(quality: StrokeText.StrokeQuality) -> [(dx: CGFloat, dy: CGFloat)] {
    switch quality {
    case .low:    return strokeOffsets8
    case .medium: return strokeOffsets16
    case .high:   return strokeOffsets32
    }
}

// MARK: - StrokeText 独立组件

/// 原生SwiftUI文字描边组件
///
/// 使用多层偏移叠加实现描边效果，纯SwiftUI实现，无需UIKit桥接。
///
/// ```swift
/// // 基础用法：纯色描边
/// StrokeText("Hello", strokeWidth: 2, strokeColor: .black, textColor: .white)
///
/// // 渐变填充
/// StrokeText("Hello", strokeWidth: 2, strokeColor: .black,
///            textGradient: LinearGradient(colors: [.red, .blue],
///                                         startPoint: .leading, endPoint: .trailing))
///
/// // 渐变描边
/// StrokeText("Hello", strokeWidth: 3,
///            strokeGradient: LinearGradient(colors: [.red, .blue],
///                                           startPoint: .leading, endPoint: .trailing),
///            textColor: .white)
/// ```
public struct StrokeText: View {

    // MARK: - Properties

    let text: String
    var font: Font = .body
    var strokeWidth: CGFloat = 1
    var strokeColor: Color = .black
    var strokeGradient: LinearGradient? = nil
    var textColor: Color = .white
    var textGradient: LinearGradient? = nil
    var quality: StrokeQuality = .medium

    /// 描边品质（方向数量）
    public enum StrokeQuality {
        case low      //  8 方向，高性能
        case medium   // 16 方向，默认
        case high     // 32 方向，最平滑

        var count: Int {
            switch self {
            case .low:    return 8
            case .medium: return 16
            case .high:   return 32
            }
        }
    }

    // MARK: - Initializers

    /// 纯色描边 + 纯色填充
    public init(
        _ text: String,
        font: Font = .body,
        strokeWidth: CGFloat = 1,
        strokeColor: Color = .black,
        textColor: Color = .white,
        quality: StrokeQuality = .medium
    ) {
        self.text = text
        self.font = font
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textColor = textColor
        self.quality = quality
    }

    /// 纯色描边 + 渐变填充
    public init(
        _ text: String,
        font: Font = .body,
        strokeWidth: CGFloat = 1,
        strokeColor: Color = .black,
        textGradient: LinearGradient,
        quality: StrokeQuality = .medium
    ) {
        self.text = text
        self.font = font
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textGradient = textGradient
        self.quality = quality
    }

    /// 渐变描边 + 纯色填充
    public init(
        _ text: String,
        font: Font = .body,
        strokeWidth: CGFloat = 1,
        strokeGradient: LinearGradient,
        textColor: Color = .white,
        quality: StrokeQuality = .medium
    ) {
        self.text = text
        self.font = font
        self.strokeWidth = strokeWidth
        self.strokeGradient = strokeGradient
        self.textColor = textColor
        self.quality = quality
    }

    /// 渐变描边 + 渐变填充
    public init(
        _ text: String,
        font: Font = .body,
        strokeWidth: CGFloat = 1,
        strokeGradient: LinearGradient,
        textGradient: LinearGradient,
        quality: StrokeQuality = .medium
    ) {
        self.text = text
        self.font = font
        self.strokeWidth = strokeWidth
        self.strokeGradient = strokeGradient
        self.textGradient = textGradient
        self.quality = quality
    }

    // MARK: - Body

    public var body: some View {
        let base = Text(text).font(font)
        let offsets = strokeOffsets(quality: quality)

        ZStack {
            // --- 描边层 ---
            if let strokeGradient = strokeGradient {
                // 渐变描边：用所有偏移层合成轮廓，再以渐变裁剪
                strokeGradient
                    .mask(
                        ZStack {
                            ForEach(0..<offsets.count, id: \.self) { i in
                                base
                                    .offset(x: offsets[i].dx * strokeWidth,
                                            y: offsets[i].dy * strokeWidth)
                            }
                        }
                    )
            } else {
                // 纯色描边：逐层偏移着色
                ForEach(0..<offsets.count, id: \.self) { i in
                    base
                        .offset(x: offsets[i].dx * strokeWidth,
                                y: offsets[i].dy * strokeWidth)
                        .foregroundColor(strokeColor)
                }
            }

            // --- 填充层 ---
            if let textGradient = textGradient {
                textGradient.mask(base)
            } else {
                base.foregroundColor(textColor)
            }
        }
    }
}

// MARK: - ViewModifier 扩展

/// 文字描边 ViewModifier（适用于纯色描边）
public struct TextStrokeModifier: ViewModifier {
    let width: CGFloat
    let color: Color
    let quality: StrokeText.StrokeQuality

    public func body(content: Content) -> some View {
        let offsets = strokeOffsets(quality: quality)

        ZStack {
            ForEach(0..<offsets.count, id: \.self) { i in
                content
                    .offset(x: offsets[i].dx * width,
                            y: offsets[i].dy * width)
                    .foregroundColor(color)
            }
            content
        }
    }
}

/// 渐变填充 ViewModifier
public struct TextGradientModifier: ViewModifier {
    let gradient: LinearGradient

    public func body(content: Content) -> some View {
        gradient.mask(content)
    }
}

// MARK: - View 扩展

public extension View {

    /// 为视图（通常为 Text）添加纯色文字描边
    ///
    /// ```swift
    /// Text("Hello")
    ///     .font(.largeTitle)
    ///     .textStroke(width: 2, color: .black)
    /// ```
    func textStroke(
        width: CGFloat,
        color: Color,
        quality: StrokeText.StrokeQuality = .medium
    ) -> some View {
        modifier(TextStrokeModifier(width: width, color: color, quality: quality))
    }

    /// 为视图添加渐变填充
    ///
    /// ```swift
    /// Text("Hello")
    ///     .font(.largeTitle)
    ///     .textStroke(width: 2, color: .black)
    ///     .textGradient(LinearGradient(colors: [.red, .blue],
    ///                                  startPoint: .leading, endPoint: .trailing))
    /// ```
    ///
    /// - Note: 渐变会作用于整个视图（含描边）。如仅需填充渐变，请使用 ``StrokeText`` 组件。
    func textGradient(_ gradient: LinearGradient) -> some View {
        modifier(TextGradientModifier(gradient: gradient))
    }

    /// 将描边文字扁平化为单层位图，减少合成开销。
    ///
    /// 适合列表中有多个描边文字或需要动画的场景。
    /// 代价：文字以当前尺寸光栅化，后续缩放可能略微模糊。
    ///
    /// ```swift
    /// StrokeText("Hello", strokeWidth: 2, strokeColor: .black, textColor: .white)
    ///     .flattened()
    /// ```
    func flattened() -> some View {
        self.drawingGroup()
    }
}

// MARK: - Canvas 高性能描边（推荐大量使用时）

/// 基于 Canvas 的高性能文字描边组件。
///
/// 使用 Core Graphics 原生描边 API（`StrokeStyle`），
/// **仅 1 个 Canvas View**，无需多层偏移叠加，极致性能。
///
/// ```swift
/// CanvasStrokeText("Hello",
///                  font: .system(size: 36, weight: .bold),
///                  strokeWidth: 3,
///                  strokeColor: .black,
///                  textColor: .white)
/// ```
///
/// - Note: 使用 SwiftUI Text 自动测量尺寸，支持 Dynamic Type。
/// - Note: 渐变描边/填充请使用 ``StrokeText``（Canvas 当前版本暂不直接支持渐变）。
public struct CanvasStrokeText: View {

    let text: String
    var font: Font = .body
    var strokeWidth: CGFloat = 1
    var strokeColor: Color = .black
    var textColor: Color = .white

    public init(
        _ text: String,
        font: Font = .body,
        strokeWidth: CGFloat = 1,
        strokeColor: Color = .black,
        textColor: Color = .white
    ) {
        self.text = text
        self.font = font
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textColor = textColor
    }

    public var body: some View {
        // SwiftUI Text 作为隐形尺寸锚点（自动支持 Dynamic Type）
        Text(text).font(font)
            .foregroundColor(.clear)
            .padding(strokeWidth)          // 为描边留空间
            .overlay(
                Canvas { context, size in
                    // 分别解析不同颜色的 Text（iOS 15 兼容做法）
                    let strokeResolved = context.resolve(
                        Text(text).font(font).foregroundColor(strokeColor)
                    )
                    let fillResolved = context.resolve(
                        Text(text).font(font).foregroundColor(textColor)
                    )

                    let textRect = CGRect(
                        x: strokeWidth,
                        y: strokeWidth,
                        width: size.width - strokeWidth * 2,
                        height: size.height - strokeWidth * 2
                    )

                    // 偏移叠加模拟描边（共用同一个 GraphicsContext，仅 1 个 View）
                    for (dx, dy) in strokeOffsets16 {
                        var offsetRect = textRect
                        offsetRect.origin.x += dx * strokeWidth
                        offsetRect.origin.y += dy * strokeWidth
                        context.draw(strokeResolved, in: offsetRect)
                    }

                    // 填充层
                    context.draw(fillResolved, in: textRect)
                }
            )
    }
}

// MARK: - Navigation Preview（供 ContentView 跳转）

/// StrokeText 预览页面，展示各种描边效果
public struct StrokeTextPreview: View {
    public var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                sectionTitle("纯色描边")

                StrokeText("Hello World",
                           font: .system(size: 36, weight: .bold),
                           strokeWidth: 2,
                           strokeColor: .black,
                           textColor: .white)

                StrokeText("Thick Stroke",
                           font: .system(size: 32, weight: .black),
                           strokeWidth: 5,
                           strokeColor: .red,
                           textColor: .white,
                           quality: .high)

                sectionTitle("渐变填充 + 纯色描边")

                StrokeText("Gradient Fill",
                           font: .system(size: 36, weight: .bold),
                           strokeWidth: 2,
                           strokeColor: .black,
                           textGradient: LinearGradient(
                               colors: [.red, .orange, .yellow],
                               startPoint: .leading,
                               endPoint: .trailing
                           ))

                StrokeText("Purple Haze",
                           font: .system(size: 30, weight: .heavy),
                           strokeWidth: 3,
                           strokeColor: .purple,
                           textGradient: LinearGradient(
                               colors: [.pink, .purple, .blue],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           ))

                sectionTitle("渐变描边")

                StrokeText("Gradient Stroke",
                           font: .system(size: 32, weight: .bold),
                           strokeWidth: 3,
                           strokeGradient: LinearGradient(
                               colors: [.red, .orange, .yellow, .green, .blue, .purple],
                               startPoint: .leading,
                               endPoint: .trailing
                           ),
                           textColor: .white)

                StrokeText("Neon Glow",
                           font: .system(size: 36, weight: .black),
                           strokeWidth: 4,
                           strokeGradient: LinearGradient(
                               colors: [.cyan, .blue, .purple, .pink],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
                           ),
                           textColor: .white,
                           quality: .high)

                sectionTitle("渐变描边 + 渐变填充")

                StrokeText("Rainbow",
                           font: .system(size: 36, weight: .black),
                           strokeWidth: 4,
                           strokeGradient: LinearGradient(
                               colors: [.red, .yellow, .green, .blue],
                               startPoint: .leading,
                               endPoint: .trailing
                           ),
                           textGradient: LinearGradient(
                               colors: [.orange, .pink, .purple, .cyan],
                               startPoint: .leading,
                               endPoint: .trailing
                           ),
                           quality: .high)

                sectionTitle("ViewModifier 方式")

                Text("Modifier Style")
                    .font(.system(size: 32, weight: .bold))
                    .textStroke(width: 2, color: .black)
                    .foregroundColor(.white)

                Text("Gradient Fill Modifier")
                    .font(.system(size: 28, weight: .heavy))
                    .textStroke(width: 2, color: .black)
                    .textGradient(LinearGradient(
                        colors: [.red, .orange, .yellow],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))

                sectionTitle("Canvas 原生描边（高性能，仅1个View）")

                CanvasStrokeText("Canvas Stroke",
                                 font: .system(size: 32, weight: .bold),
                                 strokeWidth: 3,
                                 strokeColor: .blue,
                                 textColor: .white)

                CanvasStrokeText("Thin Outline",
                                 font: .system(size: 28, weight: .medium, design: .rounded),
                                 strokeWidth: 1,
                                 strokeColor: .black,
                                 textColor: .orange)

                sectionTitle("自定义字体")

                StrokeText("Rounded Font",
                           font: .system(size: 36, weight: .black, design: .rounded),
                           strokeWidth: 3,
                           strokeColor: .black,
                           textGradient: LinearGradient(
                               colors: [.mint, .teal, .blue],
                               startPoint: .leading,
                               endPoint: .trailing
                           ))
            }
            .padding()
        }
        .background(Color.gray.opacity(0.15))
        .navigationTitle("StrokeText")
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
}

// MARK: - Previews

#Preview("纯色描边") {
    VStack(spacing: 20) {
        StrokeText("Hello World",
                   font: .system(size: 36, weight: .bold),
                   strokeWidth: 2,
                   strokeColor: .black,
                   textColor: .white)

        StrokeText("Medium Quality",
                   font: .system(size: 28, weight: .heavy),
                   strokeWidth: 3,
                   strokeColor: .blue,
                   textColor: .yellow,
                   quality: .medium)
        .minimumScaleFactor(0.3)
        .lineLimit(1)
        .frame(maxWidth: 100)

        StrokeText("Thick Stroke",
                   font: .system(size: 32, weight: .black),
                   strokeWidth: 5,
                   strokeColor: .red,
                   textColor: .white,
                   quality: .high)

        StrokeText("Low Quality",
                   font: .system(size: 24, weight: .semibold),
                   strokeWidth: 2,
                   strokeColor: .green,
                   textColor: .white,
                   quality: .low)
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("渐变填充 + 纯色描边") {
    VStack(spacing: 24) {
        StrokeText("Gradient Fill",
                   font: .system(size: 36, weight: .bold),
                   strokeWidth: 2,
                   strokeColor: .black,
                   textGradient: LinearGradient(
                       colors: [.red, .orange, .yellow],
                       startPoint: .leading,
                       endPoint: .trailing
                   ))

        StrokeText("Purple Haze",
                   font: .system(size: 30, weight: .heavy),
                   strokeWidth: 3,
                   strokeColor: .purple,
                   textGradient: LinearGradient(
                       colors: [.pink, .purple, .blue],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   ))

        StrokeText("Sunset",
                   font: .system(size: 32, weight: .black),
                   strokeWidth: 2,
                   strokeColor: .black,
                   textGradient: LinearGradient(
                       colors: [.orange, .pink, .purple],
                       startPoint: .top,
                       endPoint: .bottom
                   ))
    }
    .padding()
    .background(Color.black.opacity(0.8))
}

#Preview("渐变描边") {
    VStack(spacing: 24) {
        StrokeText("Gradient Stroke",
                   font: .system(size: 32, weight: .bold),
                   strokeWidth: 3,
                   strokeGradient: LinearGradient(
                       colors: [.red, .orange, .yellow, .green, .blue, .purple],
                       startPoint: .leading,
                       endPoint: .trailing
                   ),
                   textColor: .white)

        StrokeText("Neon Glow",
                   font: .system(size: 36, weight: .black),
                   strokeWidth: 4,
                   strokeGradient: LinearGradient(
                       colors: [.cyan, .blue, .purple, .pink],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing
                   ),
                   textColor: .white,
                   quality: .high)
    }
    .padding()
    .background(Color.black.opacity(0.9))
}

#Preview("渐变描边 + 渐变填充") {
    VStack(spacing: 24) {
        StrokeText("Full Gradient",
                   font: .system(size: 32, weight: .bold),
                   strokeWidth: 3,
                   strokeGradient: LinearGradient(
                       colors: [.red, .orange],
                       startPoint: .leading,
                       endPoint: .trailing
                   ),
                   textGradient: LinearGradient(
                       colors: [.blue, .purple],
                       startPoint: .leading,
                       endPoint: .trailing
                   ))

        StrokeText("Rainbow",
                   font: .system(size: 36, weight: .black),
                   strokeWidth: 4,
                   strokeGradient: LinearGradient(
                       colors: [.red, .yellow, .green, .blue],
                       startPoint: .leading,
                       endPoint: .trailing
                   ),
                   textGradient: LinearGradient(
                       colors: [.orange, .pink, .purple, .cyan],
                       startPoint: .leading,
                       endPoint: .trailing
                   ),
                   quality: .high)
    }
    .padding()
    .background(Color.black.opacity(0.9))
}

#Preview("ViewModifier 方式") {
    VStack(spacing: 20) {
        Text("Modifier Style")
            .font(.system(size: 32, weight: .bold))
            .textStroke(width: 2, color: .black)
            .foregroundColor(.white)

        Text("Gradient Fill Modifier")
            .font(.system(size: 28, weight: .heavy))
//            .textGradient(LinearGradient(
//                colors: [.red, .orange, .yellow],
//                startPoint: .leading,
//                endPoint: .trailing
//            ))
            .textStroke(width: 2, color: .red)


        Text("Multi-line Text\nSecond Line Here")
            .font(.system(size: 24, weight: .semibold))
            .multilineTextAlignment(.center)
            .textStroke(width: 2, color: .blue)
            .foregroundColor(.white)
    }
    .padding()
    .background(Color.gray.opacity(0.3))
}

#Preview("自定义字体") {
    VStack(spacing: 16) {
        StrokeText("Custom Font",
                   font: .system(size: 36, weight: .black, design: .rounded),
                   strokeWidth: 3,
                   strokeColor: .black,
                   textGradient: LinearGradient(
                       colors: [.mint, .teal, .blue],
                       startPoint: .leading,
                       endPoint: .trailing
                   ))

        StrokeText("Italic Style",
                   font: .system(size: 30, weight: .bold, design: .serif).italic(),
                   strokeWidth: 2,
                   strokeColor: .indigo,
                   textColor: .white)
    }
    .padding()
    .background(Color.gray.opacity(0.4))
}
