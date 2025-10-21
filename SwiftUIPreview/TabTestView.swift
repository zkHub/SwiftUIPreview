//
//  TabTestView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/9/18.
//

import SwiftUI

struct TabScrollSafeAreaTest: View {
    @State private var selected = 0

    var body: some View {
        TabView(selection: $selected) {
            
            ZStack {
                Color.green
            }
            .ignoresSafeArea()
            .tag(0)
            
            ZStack {
                Color.black
            }
            .ignoresSafeArea()
            .tag(1)
            
            ScrollView(showsIndicators: false) {
                Color.red.frame(height: 1000)
            }.tag(2)
                .ignoresSafeArea()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))        // 测试把 ignoresSafeArea 放在 TabView 上
        .ignoresSafeArea()
        .background(.blue)
        .navigationBarHidden(true)
    }
}

struct TabScrollSafeAreaTest_Previews: PreviewProvider {
    static var previews: some View {
        TabScrollSafeAreaTest()
            .previewInterfaceOrientation(.portrait)
    }
}
