//
//  ViewExt.swift
//  SwiftUIPreview
//
//  Created by zk on 2026/1/8.
//

import SwiftUI


extension View {
    // 把当前 View 渲染为 UIImage
    @available(iOS 16.0, *)
    @MainActor
    func snapshot(scale: CGFloat? = nil) -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = scale ?? UIScreen.main.scale
        var image = renderer.uiImage ?? UIImage()
        if let pngData = image.pngData(), let png = UIImage(data: pngData) {
            image = png
        }
        return image
    }
    
    func toImage(cornerRadius: CGFloat? = nil) -> UIImage {
        // 为了避免 iOS 15 在安全区导致偏移问题，忽略 SafeArea
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        // 让 UIHostingController 的视图尺寸匹配其内容
        let targetSize = controller.view.intrinsicContentSize
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        if let cornerRadius {
            controller.view.layer.cornerRadius = cornerRadius
            controller.view.layer.masksToBounds = true
        }
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let pngData = renderer.pngData { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
        var image = UIImage()
        if let png = UIImage(data: pngData) {
            image = png
        }
        return image
        
    }
}
