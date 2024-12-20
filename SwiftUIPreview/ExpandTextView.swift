import SwiftUI
import UIKit

struct DescHtmlText: View {
    @State var text: String
    @State private var height: CGFloat = .zero
    
    var body: some View {
        ExpandTextView(text: $text, font: .systemFont(ofSize: 16), height: $height)
            .frame(minHeight: height)
    }

    
}


struct ExpandTextView: UIViewRepresentable {
    @Binding var text: String
    let font: UIFont
    @Binding var height: CGFloat
    @State private var isExpanded: Bool = false

    let maxLines = 4
    let rate = 1

    func makeUIView(context: Context) -> some UITextView {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets.zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = font
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.delegate = context.coordinator
        textView.linkTextAttributes = [
                .foregroundColor: UIColor.red,
//                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        return textView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: ExpandTextView
        
        init(_ parent: ExpandTextView) {
            self.parent = parent
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if URL.absoluteString == "more://" {
                parent.isExpanded.toggle()
                return false
            }
            return true
        }
    }

    func updateUIView(_ uiView: UIViewType, context _: Context) {
        
        var attributedString = NSAttributedString(string: text, attributes: [.font: font])
        if !isExpanded {
            let preTruncate = preTruncate(text: text, width: uiView.bounds.width)
            attributedString = truncateText(uiView, text: preTruncate.text, maxHeight: preTruncate.height)
        }
        DispatchQueue.main.async {
            uiView.attributedText = attributedString
            height = uiView.sizeThatFits(CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
            print("---expandableTextHeight", height)
        }
    }
    
    // 根据最多行确定string的index和height
    private func preTruncate(text: String, width: CGFloat) -> (text: String, height: CGFloat) {
        
        let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        textContainer.lineFragmentPadding = 0.0
//        textContainer.lineBreakMode = .byTruncatingTail
        textContainer.maximumNumberOfLines = maxLines
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(string: text)
        textStorage.addAttribute(.font, value: font, range: NSRange(location: 0, length: textStorage.length))
        textStorage.addLayoutManager(layoutManager)

        
        var index = 0
        var lineRange = NSRange()
        var totalHeight: CGFloat = 0.0
        
        for _ in 0..<maxLines {
            // 计算指定位置的字形所占据行的矩形区域，并更新行范围
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: index, effectiveRange: &lineRange)
            totalHeight += lineRect.height
            // 更新索引到当前行的末尾
            index = NSMaxRange(lineRange)
            if index >= layoutManager.numberOfGlyphs {
                return (text, totalHeight)
            }
        }
        
        return ((text as NSString).substring(to: index), totalHeight)
    }
    
    func truncateText(_ uiView: UIViewType, text: String, maxHeight: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text, attributes: [.font: font])

        if !isExpanded {
            if text.count != self.text.count {
                let moreString = NSMutableAttributedString(string: "...More", attributes: [.font: font])
                moreString.addAttributes([.link: "more://", .font: font], range: NSRange(location: 3, length: moreString.length-3))
                attributedString.append(moreString)
            }
            
            let height = attributedString.boundingRect(with: CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size.height
            if height > maxHeight  {
                let truncateString = String(text.dropLast(rate))
                return truncateText(uiView, text: truncateString, maxHeight: maxHeight)
            }
        }
        return attributedString
    
    }
    
    func truncateHTMLText(_ uiView: UIViewType, text: String) -> NSAttributedString? {
        let font = uiView.font ?? UIFont.systemFont(ofSize: 16)
        let style = "<style>body{font-size:\(font.pointSize)px;line-height:22px;font-family:'-apple-system'}</style>"
        
        let lineHeight = font.lineHeight
        let maxHeight = lineHeight * CGFloat(maxLines)
                    
        if let data = (style + text).data(using: .utf8, allowLossyConversion: true),
           let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        {
            if !isExpanded {
                if text.count != self.text.count {
                    let moreString = NSMutableAttributedString(string: "...More", attributes: [.font: font])
                    moreString.addAttributes([.link: "more://", .font: font], range: NSRange(location: 3, length: moreString.length-3))
                    attributedString.append(moreString)
                }
                
                let height = attributedString.boundingRect(with: CGSize(width: uiView.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size.height
                if height > maxHeight+20  {
                    let truncateString = String(text.dropLast(rate))
                    return truncateHTMLText(uiView, text: truncateString)
                }
            }
            return attributedString
        } else {
            return nil
        }
    
    }
    

    
    
    
}
