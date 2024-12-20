//
//  MakeStickerView.swift
//  Avatar
//
//  Created by zk on 2024/9/25.
//

import SwiftUI


struct MakeStickerView: View {

    private let label = [
        "Hello Guys",
        "HOAX!!",
        "I HEAR U",
        "Correct!",
        "MUCH LOVE",
        "I LOVE YOU",
        "Excuse ME?",
        "EXCELENTE",
        "YOU ARE THE BEST",
        "LET ME SEE",
        "WHO IS TALKING",
        "I WON'T SAY ANYTHING!",
        "THANK YOU",
        "LAST WARNING",
        "BLESS YOU",
        "PLEASE",
        "PAUSE",
        "GIVE ME FIVE!",
        "Good Morning everyone",
        "Sorry",
        "NO",
        "ONE LOVE!",
        "FOR REAL？",
        "be careful",
        "YOU ARE MY BROTHER",
        "YOU'RE SWEET!"
      ]
    
    @State var renderView: MakeStickerEditor?
    
    @State private var outputImage: UIImage?
    
    // MARK: View
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                renderView
                Button {
//                    outputImage = renderView.asUIImage()
//                    renderView?.takeScreenshot(completion: { image in
//                        outputImage = image
//                    })
//                    let renderer = ImageRenderer(content: renderView)
//                    renderer.scale = UIScreen.main.scale
//                    if let image = renderer.uiImage {
//                        outputImage = image
//                    }
                } label: {
                    Text("save")
                }

                if let image = outputImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 200, height: 200)
                }
                
                
            }
            .onAppear(perform: {
                renderView = MakeStickerEditor(width: geo.size.width)
            })
            
        }

    }
    

    
    
    // MARK: Method
    
    
}

struct MakeStickerEditor: View {
    let width: CGFloat
    
    @State var text = "1234abc"
    
    var body: some View {
        VStack {
            TextEditorView(text: $text)

        }
        .frame(width: width, height: width)
        .background {
            Color.red
        }
    }
}




struct TextEditorView: View {
    
    @Binding var text: String
    
    @State private var rotation: Angle = .zero        // Text 的旋转角度
    @State private var scale: CGFloat = 1.0           // Text 的缩放比例
    @State private var lastScale: CGFloat = 1.0       // 上一次的缩放比例
    @State private var lastRotation: Angle = .zero    // 上一次的旋转角度
    @State private var initialDragLocation: CGPoint?  // 手势的起始位置
    @State private var textCenter: CGPoint = .zero

    var body: some View {
            
        Text("\(text)")
            .font(.system(size: 26, weight: .bold))
            .foregroundStyle(.blue)
            .padding()
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.textCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        }
                }
            )
            .overlay(
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .foregroundColor(.blue)
                        .overlay(alignment: .topLeading) {
                            // 左上角移除按钮
                            Button(action: {
                                
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 30, height: 30)
                            }
                            .scaleEffect(1/scale)
                        }
                        .overlay(alignment: .topTrailing) {
                            // 右上角编辑按钮
                            Button(action: {
                                
                            }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.green)
                                    .frame(width: 30, height: 30)
                            }
                            .scaleEffect(1/scale)
                        }
                    
                        .overlay(alignment: .bottomTrailing) {
                            // 右下角旋转和缩放按钮
                            Image(systemName: "arrow.up.left.and.down.right.magnifyingglass")
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30, alignment: .bottomTrailing)
                                .offset(CGSize(width: 10.0, height: 10.0))
                                .gesture(
                                    DragGesture(coordinateSpace: .named("textSpace"))
                                        .onChanged { value in
                                            if initialDragLocation == nil {
                                                initialDragLocation = value.startLocation
                                                return
                                            }
                                            
                                            let currentDragLocation = value.location

                                            // 计算旋转角度
                                            let initialAngle = calculateAngle(center: textCenter, point: initialDragLocation!)
                                            let currentAngle = calculateAngle(center: textCenter, point: currentDragLocation)
                                            print(initialAngle, currentAngle)
                                            let r = currentAngle - initialAngle
                                            rotation = lastRotation + r
                                            
                                            // 计算缩放比例
                                            let initialDistance = calculateDistance(center: CGPoint(x: 0, y: 0), point: initialDragLocation!)
                                            let currentDistance = calculateDistance(center: CGPoint(x: 0, y: 0), point: currentDragLocation)
                                            
                                            scale = max(0.5, min(3.0, lastScale * (currentDistance / initialDistance)))
                                        }
                                        .onEnded { _ in
                                            // 保存当前的旋转角度和缩放比例
                                            lastRotation = rotation
                                            lastScale = scale
                                            initialDragLocation = nil
                                            print("end----")
                                        }
                                )
                        }
                    
                }
            )
            .rotationEffect(rotation)
            .scaleEffect(scale)
            .coordinateSpace(name: "textSpace")

    }

    
    // 计算角度
    private func calculateAngle(center: CGPoint, point: CGPoint) -> Angle {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        let radians = atan2(deltaY, deltaX)
        return Angle(radians: Double(radians))
    }

    // 计算距离
    private func calculateDistance(center: CGPoint, point: CGPoint) -> CGFloat {
        let deltaX = point.x - center.x
        let deltaY = point.y - center.y
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}

extension View {
    func asUIImage() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        // 设置适当的尺寸
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        // 使用 UIGraphicsImageRenderer 渲染 SwiftUI 视图为 UIImage
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension View {
    // 扩展方法，用于对当前视图进行截图
    func takeScreenshot(completion: @escaping (UIImage?) -> Void) {
        // 使用 UIHostingController 将 SwiftUI 视图包装为 UIView
                let hostingController = UIHostingController(rootView: self)
                let view = hostingController.view

                // 设置视图的尺寸
                let targetSize = hostingController.view.intrinsicContentSize
                hostingController.view.bounds = CGRect(origin: .zero, size: targetSize)
                hostingController.view.backgroundColor = .clear

                // 获取主窗口
                guard let keyWindow = UIApplication.shared.windows.first else {
                    completion(nil)
                    return
                }

                // 将 hostingController 视图临时添加到当前窗口中
                keyWindow.addSubview(view!)

                // 确保视图完成布局
                DispatchQueue.main.async {
                    // 使用 UIGraphicsImageRenderer 进行截图
                    let renderer = UIGraphicsImageRenderer(size: targetSize)
                    let image = renderer.image { context in
                        // 设置当前上下文
//                        context.cgContext.setShouldRasterize(true)
                        context.cgContext.setAllowsAntialiasing(true)

                        // 直接渲染 layer，保留所有变换效果
                        view?.layer.render(in: context.cgContext)
                    }

                    // 完成截图后移除临时视图
                    view?.removeFromSuperview()
                    completion(image)
                }
    }
}

#Preview {
    MakeStickerView()
}
