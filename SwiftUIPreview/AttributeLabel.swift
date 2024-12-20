//
//  AttributeLabel.swift
//  SwiftUIPreview
//
//  Created by zk on 2024/12/12.
//

import SwiftUI


struct AttributeLabel: View {
    @State var attributedText: NSAttributedString
    var body: some View {
        AttributeLabelContent(attributedText: $attributedText)
    }
}

struct AttributeLabelContent: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.attributedText = attributedText
        return label
    }
    
    func updateUIView(_ uiView: UILabel, context: Context) {
        uiView.attributedText = attributedText
    }
    
}


#Preview {
    let at: NSAttributedString = {
        let at = NSMutableAttributedString(string: "描边文字123", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .bold), .foregroundColor: UIColor.white, .strokeColor: UIColor.red, .strokeWidth: -1])
        return at
    }()
    
    return AttributeLabel(attributedText: at)
}
