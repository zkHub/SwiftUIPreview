//
//  CanvasView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/1.
//


import SwiftUI

struct DrawingPath {
    var points: [CGPoint] = []
    var color: Color
    var lineWidth: CGFloat
}

struct DrawingView: View {
    @State private var paths: [DrawingPath] = []
    @State private var currentPath = DrawingPath(points: [], color: .black, lineWidth: 3)

    @State private var selectedColor: Color = .black
    @State private var lineWidth: CGFloat = 3
    @State private var isEraser: Bool = false

    var body: some View {
        VStack {
            DrawingCanvas(paths: $paths)
                .overlay(
                    GeometryReader { geo in
                        Color.clear.contentShape(Rectangle())
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let point = value.location
                                    currentPath.points.append(point)
                                    currentPath.color = isEraser ? .white : selectedColor
                                    currentPath.lineWidth = lineWidth
                                    if paths.last?.points != currentPath.points {
                                        if paths.isEmpty || paths.last?.points != currentPath.points {
                                            paths.append(currentPath)
                                        } else {
                                            paths[paths.count - 1] = currentPath
                                        }
                                    }
                                }
                                .onEnded { _ in
                                    paths.append(currentPath)
                                    currentPath = DrawingPath(points: [], color: selectedColor, lineWidth: lineWidth)
                                }
                            )
                    }
                )
                .frame(maxHeight: .infinity)

            Divider()

            HStack {
                ColorPicker("颜色", selection: $selectedColor)
                    .labelsHidden()

                Slider(value: $lineWidth, in: 1...20) {
                    Text("线宽")
                }
                .frame(width: 150)

                Toggle("橡皮擦", isOn: $isEraser)

                Button("清除") {
                    paths.removeAll()
                }

                Button("保存") {
                    saveCanvasImage()
                }
            }
            .padding()
        }
    }

    func saveCanvasImage() {
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: DrawingCanvas(paths: .constant(paths)).frame(width: 300, height: 500))
            renderer.isOpaque = true
            if let uiImage = renderer.uiImage {
                UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

struct DrawingCanvas: View {
    @Binding var paths: [DrawingPath]

    var body: some View {
        Canvas { context, size in
            for path in paths {
                var shape = Path()
                guard let first = path.points.first else { return }
                shape.move(to: first)

                for i in 1..<path.points.count {
                    let mid = CGPoint(
                        x: (path.points[i].x + path.points[i - 1].x) / 2,
                        y: (path.points[i].y + path.points[i - 1].y) / 2
                    )
                    shape.addQuadCurve(to: mid, control: path.points[i - 1])
                }
                context.stroke(shape, with: .color(path.color), style: StrokeStyle(lineWidth: path.lineWidth, lineCap: .round, lineJoin: .round))
            }
        }
        .background(Color.white)
    }
}
