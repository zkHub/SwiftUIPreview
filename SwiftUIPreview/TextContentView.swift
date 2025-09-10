import SwiftUI
import Combine

struct TextContentView: View {
    @State private var messages: [String] = []
    @State private var messageText: String = ""
    @State private var textEditorHeight: CGFloat = 40
    
    var body: some View {
        VStack {
            // 消息列表
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(messages, id: \.self) { message in
                        Text(message)
                            .padding(10)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding()
            }
            
            // 输入区域
            HStack(alignment: .bottom) {
                // 动态高度的文本编辑器
                ZStack(alignment: .leading) {
                    Text(messageText)
                        .font(.system(.body))
                        .foregroundColor(.clear)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        .background(GeometryReader { geometry in
                            Color.clear.preference(
                                key: ViewHeightKey.self,
                                value: geometry.frame(in: .local).size.height
                            )
                        })
                    
                    CustomTextView(text: $messageText, height: $textEditorHeight, onCommit: sendMessage)
                        .frame(height: max(40, textEditorHeight))
                        .padding(.horizontal, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                }
                
                // 发送按钮
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .onPreferenceChange(ViewHeightKey.self) { height in
                // 根据文本内容动态调整高度
                self.textEditorHeight = height
            }
        }
        .navigationTitle("微信式聊天")
    }
    
    func sendMessage() {
        let trimmedMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else { return }
        
        messages.append(trimmedMessage)
        messageText = ""
        textEditorHeight = 40
        
        // 隐藏键盘
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// 用于获取文本高度的PreferenceKey
struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// 自定义TextView处理键盘发送按钮
struct CustomTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    var onCommit: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        textView.backgroundColor = .clear
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        
        // 确保在主线程设置UIKit属性
        DispatchQueue.main.async {
            textView.textContentType = .none
            textView.returnKeyType = .send
            textView.enablesReturnKeyAutomatically = true
        }
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        
        // 更新高度
        let fixedWidth = uiView.frame.size.width
        let newSize = uiView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        if height != newSize.height {
            DispatchQueue.main.async {
                self.height = newSize.height
            }
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView
        
        init(_ parent: CustomTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            
            // 更新高度
            let fixedWidth = textView.frame.size.width
            let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            
            if parent.height != newSize.height {
                DispatchQueue.main.async {
                    self.parent.height = newSize.height
                }
            }
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // 检测到发送按钮被按下
            if text == "\n" {
                parent.onCommit()
                return false
            }
            return true
        }
    }
}

