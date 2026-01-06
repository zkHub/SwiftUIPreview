//
//  ColorView.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/8/29.
//

import SwiftUI


struct AColorView: View {
    
    private var Colors: [UIColor] = [
        .black,
        .darkGray,
        .lightGray,
        .white,
        .gray,
        .red,
        .green,
        .blue,
        .cyan,
        .yellow,
        .magenta,
        .orange,
        .purple,
        .brown,
        .clear,
        .systemRed,
        .systemGreen,
        .systemBlue,
        .systemOrange,
        .systemYellow,
        .systemPink,
        .systemPurple,
        .systemTeal,
        .systemIndigo,
        .systemBrown,
        .systemMint,
        .systemCyan,
        .systemGray,
        .systemGray2,
        .systemGray3,
        .systemGray4,
        .systemGray5,
        .systemGray6,
        .tintColor,
        .label,
        .secondaryLabel,
        .tertiaryLabel,
        .quaternaryLabel,
        .link,
        .placeholderText,
        .separator,
        .opaqueSeparator,
        .systemBackground,
        .secondarySystemBackground,
        .tertiarySystemBackground,
        .systemGroupedBackground,
        .secondarySystemGroupedBackground,
        .tertiarySystemGroupedBackground,
        .systemFill,
        .secondarySystemFill,
        .tertiarySystemFill,
        .quaternarySystemFill,
        .lightText,
        .darkText,
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], content: {
                ForEach(Colors, id: \.self) { color in
                    VStack {
                        Color(uiColor: color)
                            .frame(height: 50)
                        if let rgb = color.getRGBA() {
                            let rgbStr = "r: \(String(format: "%.2f", rgb.red)), g: \(String(format: "%.2f", rgb.green)), b: \(String(format: "%.2f", rgb.blue)), a: \(String(format: "%.2f", rgb.alpha))"
                            Text(rgbStr)
                                .font(.system(size: 12))
                                .onTapGesture {
                                    UIPasteboard.general.string = "Color(red: \(String(format: "%.2f", rgb.red)), green: \(String(format: "%.2f", rgb.green)), blue: \(String(format: "%.2f",rgb.blue))"
                                }
                        } else {
                            Text("rgb nil")
                        }
                        if let hex = color.toHex() {
                            Text("hex: \(hex)")
                                .onTapGesture {
                                    UIPasteboard.general.string = hex
                                }
                        }
                    }
                }
            })
        }
    }
}

#Preview {
    AColorView()
}
