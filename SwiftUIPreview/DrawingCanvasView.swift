//
//  DrawingCanvasView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/6.
//

// DrawingCanvasView.swift
// UIKit UIView 可嵌入 SwiftUI 的画板，支持颜色选择、橡皮擦、线宽调节与导出图像

import UIKit

enum DrawMode {
    case pen
    case eraser
}

class DrawingCanvasView: UIView {
    var strokeColor: UIColor = .black         // 当前画笔颜色
    var strokeWidth: CGFloat = 5.0            // 当前画笔宽度
    var drawMode: DrawMode = .pen             // 当前绘图模式：画笔或橡皮擦

    private var paths: [(path: UIBezierPath, color: UIColor, width: CGFloat, mode: DrawMode)] = []
    private var currentPath: UIBezierPath?
    private var previousPoint: CGPoint?       // 上一个触摸点，用于路径平滑插值
    private var drawingImage: UIImage?        // 合成后的缓存图层，提高性能
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .clear
        isMultipleTouchEnabled = false
    }
    
    // 开始触摸时初始化路径并记录起点
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }

        currentPath = UIBezierPath()
        currentPath?.lineWidth = strokeWidth
        currentPath?.lineCapStyle = .round
        currentPath?.move(to: point)
        previousPoint = point
    }

    // 移动时通过二次贝塞尔曲线平滑路径
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
              let path = currentPath,
              let previousPoint = previousPoint else { return }

        // 取中点用于平滑曲线
        let midPoint = CGPoint(x: (previousPoint.x + point.x) / 2,
                               y: (previousPoint.y + point.y) / 2)
        path.addQuadCurve(to: midPoint, controlPoint: previousPoint)
        self.previousPoint = point
        setNeedsDisplay()
    }

    // 结束时缓存到图层中以优化性能
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let path = currentPath else { return }

        // 保存路径信息用于图层绘制
        paths.append((path, strokeColor, strokeWidth, drawMode))
        drawPathOntoImage(path: path, color: strokeColor, width: strokeWidth, mode: drawMode)

        currentPath = nil
        previousPoint = nil
        setNeedsDisplay()
    }

    // 主绘图函数，每次刷新绘制缓存 + 当前路径
    override func draw(_ rect: CGRect) {
        drawingImage?.draw(in: bounds)

        guard let path = currentPath else { return }
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(strokeWidth)
        context?.setShouldAntialias(true)
        context?.setAllowsAntialiasing(true)
        
        if drawMode == .pen {
            strokeColor.setStroke()
            path.stroke()
        } else if drawMode == .eraser {
            context?.setBlendMode(.clear)
            UIColor.clear.setStroke()
            path.stroke(with: .clear, alpha: 1)
            context?.setBlendMode(.normal)
        }
    }

    // 将路径合成到缓存图层，提高绘制效率
    private func drawPathOntoImage(path: UIBezierPath, color: UIColor, width: CGFloat, mode: DrawMode) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawingImage?.draw(in: bounds)

        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(width)
        context?.setShouldAntialias(true)
        context?.setAllowsAntialiasing(true)

        if mode == .pen {
            color.setStroke()
            path.stroke()
        } else {
            context?.setBlendMode(.clear)
            UIColor.clear.setStroke()
            path.stroke()
            context?.setBlendMode(.normal)
        }

        drawingImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }

    // 清空画布
    func clearCanvas() {
        drawingImage = nil
        paths.removeAll()
        setNeedsDisplay()
    }
    
}


class ImageDrawingView: UIView {
    var strokeColor: UIColor = .black {
        didSet {
            drawingCanvasView.strokeColor = strokeColor
        }
    }
    var strokeWidth: CGFloat = 5.0 {
        didSet {
            drawingCanvasView.strokeWidth = strokeWidth
        }
    }
    var drawMode: DrawMode = .pen {
        didSet {
            drawingCanvasView.drawMode = drawMode
        }
    }
    var baseImage: String = "" {
        didSet {
            imgView.image = UIImage(named: baseImage)
        }
    }
    
    private var drawingCanvasView = DrawingCanvasView()
    private var imgView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(imgView)
        sendSubviewToBack(imgView)
        imgView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        addSubview(drawingCanvasView)
        drawingCanvasView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
    }
    
    // 清空画布
    func clearCanvas() {
        drawingCanvasView.clearCanvas()
    }

    // 导出最终图像，原图 + 绘制层
    func exportImage() -> UIImage? {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = true // 若背景是完全不透明图像可设为 true
        let renderer = UIGraphicsImageRenderer(size: bounds.size, format: format)
        return renderer.image { context in
            // 将整个视图（包含背景图和绘图）渲染为图片
            layer.render(in: context.cgContext)
        }
    }

    
}


// SwiftUI 封装 UIViewRepresentable
import SwiftUI

struct DrawingCanvasRepresentable: UIViewRepresentable {
    @Binding var strokeColor: UIColor
    @Binding var strokeWidth: CGFloat
    @Binding var drawMode: DrawMode
    var baseImage: String = ""
    // 新增回调，让 SwiftUI 外层获取 UIView 引用
    var onCanvasViewReady: ((ImageDrawingView) -> Void)? = nil

    class Coordinator {
        var parent: DrawingCanvasRepresentable
        init(parent: DrawingCanvasRepresentable) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> ImageDrawingView {
        let view = ImageDrawingView()
        view.strokeColor = strokeColor
        view.strokeWidth = strokeWidth
        view.drawMode = drawMode
        view.baseImage = baseImage
        DispatchQueue.main.async {
            onCanvasViewReady?(view)
        }
        return view
    }

    func updateUIView(_ uiView: ImageDrawingView, context: Context) {
        uiView.strokeColor = strokeColor
        uiView.strokeWidth = strokeWidth
        uiView.drawMode = drawMode
    }
}


// 示例 SwiftUI 页面
struct DrawingOverlayView: View {
    @State private var strokeColor: UIColor = .red
    @State private var strokeWidth: CGFloat = 5
    @State private var drawMode: DrawMode = .pen
    @State private var canvasView: ImageDrawingView? = nil

    let baseImage: UIImage

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: baseImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0)
                    .overlay {
                        DrawingCanvasRepresentable(strokeColor: $strokeColor, strokeWidth: $strokeWidth, drawMode: $drawMode, baseImage: "2") { view in
                            canvasView = view
                        }
                    }
            }

            HStack {
                Button("画笔") {
                    drawMode = .pen
                }
                Button("橡皮") {
                    drawMode = .eraser
                }
                ColorPicker("颜色", selection: Binding(get: {
                    Color(strokeColor)
                }, set: {
                    strokeColor = UIColor($0)
                }))
                Slider(value: $strokeWidth, in: 1...20, step: 1)
                Button("导出") {
                    if let image = canvasView?.exportImage() {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                }
                Button("清除") {
                    canvasView?.clearCanvas()
                }
            }.padding()
        }
    }
}

