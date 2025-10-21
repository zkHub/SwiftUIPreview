//
//  TestPickerView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/9/26.
//

import SwiftUI
import UIKit
@_spi(Advanced) import SwiftUIIntrospect

class WheelPickerStore: NSObject, ObservableObject, UIPickerViewDataSource, UIPickerViewDelegate {
    var options: [String]
    @Published var selection: Int = 0

    init(options: [String]) {
        self.options = options
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }
    
    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reused = view as? UILabel {
            label = reused
        } else {
            label = UILabel()
        }

        let option = options[row]
        label.text = option
        label.textAlignment = .center
        if selection == row {
            label.textColor = .red
        } else {
            label.textColor = .gray
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 46
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selection = row
    }
    
    func selectedOption() -> String? {
        if options.count <= 0 { return nil }
        return options[selection]
    }
    
}


struct WheelPickerView: View {
    @ObservedObject var store: WheelPickerStore
    @State private var selected = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    
                } label: {
                    Text("Cancel")
                        .frame(height: 18)
                        .padding(16)
                }

                Spacer()
                
                Text("Please Select")
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("Confirm")
                        .frame(height: 18)
                        .padding(16)
                }
                
            }
            
            Picker("", selection: $selected) {
            }
            .pickerStyle(.wheel)
            .frame(height: 160)
            .overlay {
                VStack(spacing: 45) {
                    Color.gray.frame(height: 0.5)
                    Color.gray.frame(height: 0.5)
                }
            }
            .introspect(.picker(style: .wheel), on: .iOS(.v15...)) { pickerView in
                pickerView.delegate = store
                pickerView.dataSource = store
                pickerView.selectRow(store.selection, inComponent: 0, animated: false)
                for subview in pickerView.subviews {
                    if subview.backgroundColor != nil {
                        subview.backgroundColor = .clear
                    }
                }
            }
        }
        .background(.black.opacity(0.6))
    }
}


struct WheelPickerView1: View {
    @State private var selected = Option(id: 0, title: "Option 0")
    let options = (0..<10).map { Option(id: $0, title: "Option \($0)") }

    @StateObject private var store = WheelPickerStore(options: (0..<10).map { "Option \($0)" })
    @State private var width: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            
            VStack {
                Text("Selected: \(store.selectedOption())")
                UIPickerWrapper(width: geo.size.width, selection: $selected, options: options,
                                selectedFont: .systemFont(ofSize: 24, weight: .bold),
                                nonSelectedFont: .systemFont(ofSize: 18),
                                selectedTextColor: .red,
                                nonSelectedTextColor: .gray)
                //                .frame(height: 150)
//                                .frame(maxWidth: .infinity)
                .frame(width: geo.size.width)
                .overlay {
                    VStack(spacing: 45) {
                        Color.blue.frame(height: 1)
                        Color.blue.frame(height: 1)
                    }
                }
                .frame(maxWidth: .infinity)

                
                Picker("", selection: $selected) {
//                    ForEach(store.options.indices, id: \.self) { index in
//                        Text("\(store.options[index])")
//                    }
                }
                .pickerStyle(.wheel)
                .padding(.horizontal, -10)
                .overlay {
                    VStack(spacing: 45) {
                        Color.blue.frame(height: 1)
                        Color.blue.frame(height: 1)
                    }
                }
                .introspect(.picker(style: .wheel), on: .iOS(.v15...)) { pickerView in
                    pickerView.delegate = store
                    pickerView.dataSource = store
                    pickerView.selectRow(store.selection, inComponent: 0, animated: false)
                    for subview in pickerView.subviews {
                        if subview.backgroundColor != nil {
                            subview.backgroundColor = .clear
                        }
                    }
                }
                
            }
        }
    }
}


// 假设你有一个可识别的／Hashable 类型
struct Option: Hashable {
    let id: Int
    let title: String
}

struct UIPickerWrapper: UIViewRepresentable {
    var width: CGFloat
    @Binding var selection: Option
    let options: [Option]
    
    
    // 可选的样式设置（字体、颜色等）
    var selectedFont: UIFont = .systemFont(ofSize: 15)
    var nonSelectedFont: UIFont = .systemFont(ofSize: 14)
    var selectedTextColor: UIColor = .systemBlue
    var nonSelectedTextColor: UIColor = .black

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.backgroundColor = .red.withAlphaComponent(0.5)
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        // 初始滚动到选中行
        if let idx = options.firstIndex(of: selection) {
            picker.selectRow(idx, inComponent: 0, animated: false)
        }
        for subview in picker.subviews {
            if subview.backgroundColor != nil {
                subview.backgroundColor = .clear
            }
        }
//        picker.frame = CGRect(origin: .zero, size: CGSize(width: width, height: picker.frame.height))
        return picker
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        // 当 SwiftUI 侧 selection 改变时，让 UIPicker 也滚动过去
        if let idx = options.firstIndex(of: selection) {
            uiView.selectRow(idx, inComponent: 0, animated: true)
        }
        // 强制刷新 row 以重新设置字体 / 颜色（可选）
        uiView.reloadAllComponents()
//        uiView.frame = CGRect(origin: .zero, size: CGSize(width: width, height: uiView.frame.height))
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: UIPickerWrapper

        init(_ parent: UIPickerWrapper) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.options.count
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selection = parent.options[row]
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            let label: UILabel
            if let reused = view as? UILabel {
                label = reused
            } else {
                label = UILabel()
            }
            
            let option = parent.options[row]
            label.text = option.title
            // 判断是不是当前选中行
            if option == parent.selection {
                label.font = parent.selectedFont
                label.textColor = parent.selectedTextColor
            } else {
                label.font = parent.nonSelectedFont
                label.textColor = parent.nonSelectedTextColor
            }
            label.textAlignment = .center
            return label
        }
        
//        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//            parent.width
//        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            46
        }
    }
}


struct OCTopView: View {
    @State private var guideIndex = 1
    @State private var holeRect: CGRect = .zero
    
    var body: some View {
        VStack {
            
            LinearGradient(colors: [Color(hex: "D7D1F8"), Color(hex: "F1CCF8"), Color(hex: "F6F1E5")], startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    Color.white.frame(height: 20)
                        .cornerRadius(20)
                }
                .overlay(alignment: .leading) {
                    Button {
                        
                    } label: {
                        Image(systemName: "xmark").resizable().frame(width: 22, height: 22)
                            .padding(16)
                            .offset(y: 10)
                    }
                }
            
            
            Spacer()
        }
        .overlay(alignment: .top) {
            
            HStack(spacing: 35) {
                VStack(spacing: 0) {
                    Text("OC Profile").font(.VAGRoundedNextBlack(size: 30))
                        .foregroundStyle(LinearGradient(colors: [Color(hex: "583CF5"), Color(hex: "751BED")], startPoint: .leading, endPoint: .trailing))
                    
                    Text("Make your own unique OC").font(.VAGRoundedNextMedium(size: 12)).foregroundStyle(Color(hex: "#5E49F5").opacity(0.6))
                        .offset(y: -5)
                }
                .background {
                    Image("icon_oc_titlebg").padding(5)
                        .offset(y: 6)
                }
                .overlay(alignment: .topLeading) {
                    Image("icon_star_blue2").resizable().frame(width: 12, height: 12)
                }
                .overlay(alignment: .topTrailing) {
                    Image("icon_star_blue1").resizable().frame(width: 12, height: 12)
                }
                
                VStack {
                    Image("icon_top_occard").resizable().frame(width: 66, height: 67).zIndex(1)
                    
                    Image("like").resizable().frame(width: 120, height: 120)
                        .background(.white)
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                
                            } label: {
                                HStack(spacing: 0) {
                                    Text("Change").font(.PoppinsLatinMedium(size: 9)).foregroundStyle(Color.white)
                                    
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color.white)
                                        .frame(width: 3, height: 6)
                                }
                                .frame(width: 57, height: 18)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Capsule())
                                .padding(10)
                            }

                        }
                        .cornerRadius(15)
                        .overlay {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white, lineWidth: 5)
                        }
                        .rotationEffect(Angle(degrees: 5))
                        .background {
                            if guideIndex == 1 {
                                GeometryReader{ geo in
                                    let frame = geo.frame(in: .global)
                                    Color.clear
                                        .onAppear {
                                            holeRect = frame
                                        }
                                        .onChange(of: frame) { newValue in
                                            holeRect = newValue
                                        }
                                }
                            }
                        }
                        .offset(x: -12, y: -26)
                        .shadow(color: Color.black.opacity(0.15), radius: 16, y: 10)
                }
                
            }
            
        }
        .ignoresSafeArea()
        .overlay {
            guideView()
        }
    }
    
    @ViewBuilder
    func guideView() -> some View {
        if guideIndex > 0 {
            GeometryReader { geo in
                let screenRect = geo.frame(in: .local)
                if guideIndex == 1 {
                    ZStack {
                        // 半透明遮罩 + 镂空区域
                        let rect = holeRect// CGRectMake(holeRect.minX-2.5, holeRect.minY-2.5, holeRect.width+5, holeRect.height+5)
                        let corner = 15.0
                        Path { path in
                            path.addRect(screenRect)
                            // 绘制 holeRect 对应的区域
                            var hole = Path()
                            hole.addRoundedRect(in: rect, cornerSize: CGSize(width: corner, height: corner))

                            // ⚙️ 计算绕中心旋转 + 平移的变换
                            let center = CGPoint(x: rect.midX, y: rect.midY)
                            var transform = CGAffineTransform.identity
                            transform = transform
                                .translatedBy(x: center.x, y: center.y)
                                .rotated(by: CGFloat(Angle(degrees: 5).radians))
                                .translatedBy(x: -center.x, y: -center.y)
                            // 应用变换
                            path.addPath(hole.applying(transform))
                        }
                        .fill(Color.black.opacity(0.55), style: FillStyle(eoFill: true))
                        
                        
                        // 边框叠加在 holeRect 上
                        Image("img_border_oc").resizable()
                            .frame(width: 132, height: 130)
                            .position(x: rect.midX, y: rect.midY)
                        
                        VStack(alignment: .trailing, spacing: 10) {
                            Color.clear.frame(height: holeRect.maxY)
                            
                            Image("img_guide_oc_create_avatar").resizable().frame(width: 280, height: 81)
                                .overlay(alignment: .bottom) {
                                    Text("Thanks for creating me. Give me ID info to live happily here~").font(.PoppinsLatinMedium(size: 12))
                                        .foregroundStyle(Color(hex: "333333"))
                                        .multilineTextAlignment(.center)
                                        .frame(width: 240, height: 44)
                                        .padding(.bottom, 12)
                                }
                                .padding(.trailing, screenRect.width-rect.maxX)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle()) // 指定整块区域都可点击
                        .onTapGesture {
                            guideIndex = 2
                        }
                    }
                } else if guideIndex == 2 {
                    ZStack {
                        // 半透明遮罩 + 镂空区域
                        let rect = CGRectMake(holeRect.minX, holeRect.minY, holeRect.width, holeRect.height)
                        let corner = 14.0
                        Path { path in
                            path.addRect(screenRect)
                            path.addRoundedRect(in: rect, cornerSize: CGSize(width: corner, height: corner))
                        }
                        .fill(Color.black.opacity(0.55), style: FillStyle(eoFill: true))
                        
                        // 边框叠加在 holeRect 上
                        Image("img_border_ocset").resizable()
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Spacer()
                            
                            VStack(spacing: 10) {
                                
                                Image("img_guide_arrow")
                                    .resizable()
                                    .frame(width: 52, height: 63, alignment: .center)
                                    .offset(x: -50)
                            }
                            .padding(.leading, rect.minX + 30)
                            
                            Color.clear
                                .frame(height: screenRect.height - holeRect.minY)
                        }
                        .contentShape(Rectangle()) // 指定整块区域都可点击
                        .onTapGesture {
                            guideIndex = 0
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
    
    
}



#Preview {
//    OCTopView()
    WheelPickerView(store: WheelPickerStore(options: (0..<10).map { "Option \($0)" }))
//        .frame(width: 500)
}
