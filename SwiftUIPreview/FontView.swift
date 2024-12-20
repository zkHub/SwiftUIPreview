//
//  FontView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/9/2.
//

import SwiftUI

struct FontView: View {
    
    var fonts: [UIFont] {
        var fonts: [UIFont] = [UIFont]()
        for family in UIFont.familyNames {
            print("-----")
            print(family, ":")
            for name in UIFont.fontNames(forFamilyName: family) {
                if let font = UIFont(name: name, size: 20) {
                    fonts.append(font)
                    print(name)
                }
            }
        }
        return fonts
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(fonts, id: \.self) { font in
                    Text("\(font.fontName)")
                        .font(Font.custom(font.fontName, size: font.pointSize))
                    Text("\(font.familyName) - \(font.fontName)")
                        .font(.system(size: font.pointSize))
                    Divider()
                }
            }
        }
    }
}


#Preview {
    FontView()
}
