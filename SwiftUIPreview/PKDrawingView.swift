//
//  DrawingView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/6.
//

import SwiftUI
import PencilKit

struct PKDrawingView: View {
    @State private var canvasView = PKCanvasView()
    @State private var isEraserActive = false
    @State private var selectedColor = UIColor.black
    @State private var lineWidth: CGFloat = 5

    private var inkingTool: PKInkingTool {
        PKInkingTool(.pen, color: selectedColor, width: lineWidth)
    }

    var body: some View {
        VStack(spacing: 16) {
            PencilCanvasView(canvasView: $canvasView)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: 2)
                .padding()

            HStack(spacing: 16) {
                Button(action: toggleTool) {
                    Label(isEraserActive ? "画笔" : "橡皮", systemImage: isEraserActive ? "pencil" : "eraser")
                        .labelStyle(TitleAndIconLabelStyle())
                }

                ColorPicker("颜色", selection: Binding(get: {
                    Color(selectedColor)
                }, set: { newColor in
                    selectedColor = UIColor(newColor)
                    updateTool()
                }))
                .labelsHidden()

                VStack(alignment: .leading) {
                    Text("线宽: \(Int(lineWidth))")
                    Slider(value: $lineWidth, in: 1...30, step: 1) {
                        Text("Line Width")
                    }
                    .frame(width: 120)
                    .onChange(of: lineWidth) { _ in updateTool() }
                }

                Spacer()

                Button("保存图片") {
                    saveDrawing()
                }
            }
            .padding(.horizontal)
        }
    }

    func toggleTool() {
        isEraserActive.toggle()
        updateTool()
    }

    func updateTool() {
        canvasView.tool = isEraserActive
            ? PKEraserTool(.vector)
            : inkingTool
    }

    func saveDrawing() {
        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct PencilCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let toolPicker = PKToolPicker()

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
}
