//
//  DrawingCanvasView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/6.
//

// DrawingCanvasView.swift
// UIKit UIView 可嵌入 SwiftUI

import UIKit

enum DrawMode {
    case pen
    case eraser
}

class DrawingCanvasView: UIView {
    var strokeColor: UIColor = .black
    var strokeWidth: CGFloat = 5.0
    var drawMode: DrawMode = .pen

    private var paths: [(path: UIBezierPath, color: UIColor, width: CGFloat, mode: DrawMode)] = []
    private var currentPath: UIBezierPath?
    private var previousPoint: CGPoint?
    
    private var drawingImage: UIImage? // 合成后的缓存图层

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isMultipleTouchEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        currentPath = UIBezierPath()
        currentPath?.lineWidth = strokeWidth
        currentPath?.lineCapStyle = .round
        currentPath?.move(to: point)
        previousPoint = point
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
              let path = currentPath,
              let previousPoint = previousPoint else { return }

        let midPoint = CGPoint(x: (previousPoint.x + point.x) / 2,
                               y: (previousPoint.y + point.y) / 2)
        path.addQuadCurve(to: midPoint, controlPoint: previousPoint)
        self.previousPoint = point
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let path = currentPath else { return }

        // 添加路径并合成进缓存图层
        paths.append((path, strokeColor, strokeWidth, drawMode))
        drawPathOntoImage(path: path, color: strokeColor, width: strokeWidth, mode: drawMode)

        currentPath = nil
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        drawingImage?.draw(in: bounds)

        guard let path = currentPath else { return }
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(strokeWidth)
        
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

    private func drawPathOntoImage(path: UIBezierPath, color: UIColor, width: CGFloat, mode: DrawMode) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        drawingImage?.draw(in: bounds)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineCap(.round)
        context?.setLineWidth(width)

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

    func clearCanvas() {
        drawingImage = nil
        paths.removeAll()
        setNeedsDisplay()
    }

    func exportImage(over image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        image.draw(in: bounds)
        drawingImage?.draw(in: bounds)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}


// SwiftUI Wrapper
import SwiftUI

struct DrawingCanvasRepresentable: UIViewRepresentable {
    @Binding var strokeColor: UIColor
    @Binding var strokeWidth: CGFloat
    @Binding var drawMode: DrawMode

    class Coordinator {
        var parent: DrawingCanvasRepresentable
        init(parent: DrawingCanvasRepresentable) {
            self.parent = parent
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> DrawingCanvasView {
        let view = DrawingCanvasView()
        view.strokeColor = strokeColor
        view.strokeWidth = strokeWidth
        view.drawMode = drawMode
        return view
    }

    func updateUIView(_ uiView: DrawingCanvasView, context: Context) {
        uiView.strokeColor = strokeColor
        uiView.strokeWidth = strokeWidth
        uiView.drawMode = drawMode
    }

    static func dismantleUIView(_ uiView: DrawingCanvasView, coordinator: Coordinator) {
        // clean up if needed
    }
}


// Example SwiftUI Usage
struct DrawingOverlayView: View {
    @State private var strokeColor: UIColor = .red
    @State private var strokeWidth: CGFloat = 5
    @State private var drawMode: DrawMode = .pen

    let baseImage: UIImage

    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: baseImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                DrawingCanvasRepresentable(strokeColor: $strokeColor, strokeWidth: $strokeWidth, drawMode: $drawMode)
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
                    // 导出逻辑建议放入 DrawingCanvasView 实例方法中调用
                }
            }.padding()
        }
    }
}

