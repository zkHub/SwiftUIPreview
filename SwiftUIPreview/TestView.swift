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
