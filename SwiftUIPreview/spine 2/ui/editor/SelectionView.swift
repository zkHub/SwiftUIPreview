import SwiftUI
import Kingfisher

/// 选择视图，对应 Android 的 SelectionFragment
struct SelectionView: View {
    @Binding var selectionIndex: Int
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        if let editor = viewModel.editor {
            let selections = editor.template.selections.sorted { $0.playIndex < $1.playIndex }
            
            VStack(spacing: 0) {
                // Tab 指示器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(selections.enumerated()), id: \.element.id) { index, selection in
                            SelectionTabView(
                                selection: selection,
                                isSelected: index == selectionIndex,
                                hasSelectedSku: hasSelectedSku(in: selection),
                                onTap: {
                                    withAnimation {
                                        selectionIndex = index
                                        viewModel.updatePaletteVisibility(selectionIndex: index)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // SKU 列表
                if selectionIndex < selections.count {
                    let currentSelection = selections[selectionIndex]
                    SkuGridView(
                        skus: currentSelection.skus
                    )
                }
            }
        }
    }
    
    private func hasSelectedSku(in selection: SpineSelection) -> Bool {
        let array = viewModel.avatar.skus
        let selectedSkus = Set(array)
        return selection.skus.contains { selectedSkus.contains($0.id) }
    }
}

/// 选择 Tab 视图
struct SelectionTabView: View {
    let selection: SpineSelection
    let isSelected: Bool
    let hasSelectedSku: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            KFImage(URL(string: selection.coverUrl))
                .resizable()
                .frame(width: 60, height: 60)
//            AsyncImage(url: URL(string: selection.coverUrl)) { image in
//                image
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            } placeholder: {
//                Color.gray
//            }
//            .frame(width: 60, height: 60)
//            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            
            if hasSelectedSku {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .onTapGesture {
            onTap()
        }
    }
}

/// SKU 网格视图
struct SkuGridView: View {
    let skus: [SpineSku]
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(skus, id: \.id) { sku in
                    SkuItemView(
                        sku: sku,
                        isSelected: viewModel.isSkuSelected(skuId: sku.id)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

/// SKU 项目视图
struct SkuItemView: View {
    let sku: SpineSku
    let isSelected: Bool
    @EnvironmentObject var viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack(spacing: 4) {
            // 显示皮肤缩略图
            if let image = viewModel.getSkinBitmap(skinName: sku.skinName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            }
            
            // Pro 标识
            if sku.pro > 0 {
                Text("Pro")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(4)
            }
        }
        .onTapGesture {
            viewModel.toggleSelectSku(sku)
        }
    }
}

