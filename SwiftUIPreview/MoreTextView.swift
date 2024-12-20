//
//  MoreTextView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/28.
//

import SwiftUI


struct MoreTextView: View {
    @State private var text: String = """
这是一个很长的文本，它包含了很多内容，并且会超过四行显示。这里的内容将会被截断，并显示一个 '...More' 按钮，点击按钮后，完整内容会显示出来。
这是一个很长的文本，它包含了很多内容，并且会超过四行显示。这里的内容将会被截断，并显示一个 '...More' 按钮，点击按钮后，完整内容会显示出来。
这是一个很长的文本，它包含了很多内容，并且会超过四行显示。这里的内容将会被截断，并显示一个 '...More' 按钮，点击按钮后，完整内容会显示出来。
这是一个很长的文本，它包含了很多内容，并且会超过四行显示。这里的内容将会被截断，并显示一个 '...More' 按钮，点击按钮后，完整内容会显示出来。
"""
    @State private var height: CGFloat = 0
    
    var body: some View {
        ExpandTextView(text: $text, font: .systemFont(ofSize: 16), height: $height)
            .frame(height: height)
        
        Text("描边文字")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.red)  // 内部文字颜色
            .shadow(color: .blue, radius: 1, x: 1, y: 1)
            .shadow(color: .blue, radius: 1, x: -1, y: 1)

    }
}


#Preview {
    MoreTextView()
}
