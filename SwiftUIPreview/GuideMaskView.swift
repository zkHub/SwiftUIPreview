//
//  GuideMaskView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/4/16.
//

import SwiftUI



struct GuideMaskView: View {
    let holeRect: CGRect = CGRect(x: 100, y: 100, width: 100, height: 100) // 镂空区域的位置（相对屏幕）

    
    var body: some View {
        
//        ZStack {
//            Canvas { context, size in
//                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.blue.opacity(0.5)))
//                let rect = CGRect(x: 100, y: 100, width: 100, height: 100)
//                let roundedRect = Path(roundedRect: rect, cornerRadius: 10)
//                context.blendMode = .destinationOut
//                context.fill(roundedRect, with: .color(.black))
//                context.stroke(roundedRect, with: .color(.red), lineWidth: 2)
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//        }
        
        GeometryReader { proxy in
            let screenRect = proxy.frame(in: .local)
            ZStack {
                // 半透明遮罩 + 镂空区域
                Path { path in
                    path.addRect(screenRect)
                    path.addRoundedRect(in: holeRect, cornerSize: CGSize(width: 8, height: 8))
                }
                .fill(Color.black.opacity(0.7), style: FillStyle(eoFill: true))
                
                // 红色边框叠加在 holeRect 上
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.red, lineWidth: 2)
                    .frame(width: holeRect.width, height: holeRect.height)
                    .position(x: holeRect.midX, y: holeRect.midY)
                
            }
        }
        .ignoresSafeArea()

        
    }

}


#Preview {
    GuideMaskView()
}
