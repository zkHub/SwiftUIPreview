//
//  TestView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/6/25.
//

import SwiftUI


struct TestView: View {
    var body: some View {
        VStack {
            Spacer()
            ZStack(alignment: .bottom) {
                LottieView(animation: .named("swipeLeft"))
                    .playing(loopMode: .loop)  // 或 .playing(), .paused()
                    .frame(width: 200, height: 200)
                    .background(Color.black)
                
                
                LoadingDotsView()
                
                Image("bg_tip_follow")
                    .resizable()
                    .frame(width: 316, height: 71)
                
                Text("Follow after watching!")
                    .font(.PoppinsLatinBold(size: 13))
                    .foregroundStyle(Color.white)
                    .minimumScaleFactor(0.5)
                    .frame(width: 160, height: 38)
                    .padding(.bottom, 16)
                                
                ZStack(alignment: .trailing) {
                    Text("Follow")
                        .font(.PoppinsLatinBold(size: 11))
                        .foregroundStyle(Color(hex: "333333"))
                        .minimumScaleFactor(0.5)
                        .frame(width: 57, height: 24)
                        .background(Color(hex: "FFE968"))
                        .clipShape(Capsule())
                        .background {
                            Capsule()
                                .shadow(color: Color(hex: "B80071"), radius: 0, y: 2.5)
                        }
                        .padding(.bottom, 24)
                        .offset(x: 110)
                }
                .frame(maxWidth: .infinity)
            }
            .frame(width: 316, height: 71)
            Color.clear.frame(height: 2)

        }
//        Color.clear.frame(height: 2)
    }
}

#Preview {
    TestView()
}

struct LoadingDotsView: View {
    @State private var dotCount = 1
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    let maxDots: Int = 3

    var body: some View {
        let dots = String(repeating: ".", count: dotCount)
        Text("Loading\(dots)")
            .onReceive(timer) { _ in
                dotCount = dotCount % maxDots + 1
            }
    }
}
