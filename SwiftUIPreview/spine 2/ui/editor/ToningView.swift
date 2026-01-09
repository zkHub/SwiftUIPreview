import SwiftUI

/// 调色视图，对应 Android 的 ToningFragment
struct ToningView: View {
    let selectionIndex: Int
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        let toningSets = viewModel.getToningSets(selectionIndex: selectionIndex)
        
        if toningSets.isEmpty {
            Text("没有可用的调色方案")
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 0) {
                // Tab 指示器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(toningSets, id: \.sku.id) { toningSet in
                            ToningTabView(
                                toningSet: toningSet
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // 调色方案内容
                if let firstToningSet = toningSets.first {
                    if firstToningSet.tonings.count == 1 {
                        ColorView(
                            toning: firstToningSet.tonings[0]
                        )
                    } else {
                        ToningSectionView(
                            tonings: firstToningSet.tonings
                        )
                    }
                }
            }
        }
    }
}

/// 调色 Tab 视图
struct ToningTabView: View {
    let toningSet: ToningSet
    //    @ObservedObject var viewModel: SpineEditorViewModel
        @EnvironmentObject var viewModel: SpineEditorViewModel
    var body: some View {
        VStack {
            if let image = viewModel.getSkinBitmap(skinName: toningSet.sku.skinName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
            }
        }
    }
}

/// 颜色视图，对应 Android 的 ColorFragment
struct ColorView: View {
    let toning: Toning
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(toning.colors, id: \.id) { colorSet in
                    ColorItemView(
                        colorSet: colorSet,
                        toningId: toning.id,
                        isSelected: viewModel.isColorSelected(toningId: toning.id, colorId: colorSet.id)
//                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

/// 颜色项目视图
struct ColorItemView: View {
    let colorSet: ColorSet
    let toningId: String
    let isSelected: Bool
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            // 显示渐变色预览
//            if let firstColor = colorSet.colors.first {
                let gradient = LinearGradient(
                    colors: [Color(hex: colorSet.light), Color(hex: colorSet.dark)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(gradient)
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
//            }
        }
        .onTapGesture {
            viewModel.selectColor(toningId: toningId, colorId: colorSet.id)
        }
    }
    
    private func hexToColor(_ hex: String) -> Color {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }
        
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)
        
        let r, g, b: Double
        switch cleaned.count {
        case 8: // RRGGBBAA
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
        case 6: // RRGGBB
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x000000FF) / 255.0
        default:
            return .white
        }
        
        return Color(red: r, green: g, blue: b)
    }
}

/// 调色方案视图，对应 Android 的 ToningSectionFragment
struct ToningSectionView: View {
    let tonings: [Toning]
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(tonings, id: \.id) { toning in
                    VStack(alignment: .leading, spacing: 8) {
                        if let name = toning.name {
                            Text(name)
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(toning.colors, id: \.id) { colorSet in
                                    ColorItemView(
                                        colorSet: colorSet,
                                        toningId: toning.id,
                                        isSelected: viewModel.isColorSelected(toningId: toning.id, colorId: colorSet.id)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

