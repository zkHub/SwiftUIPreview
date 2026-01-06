import SwiftUI

// SkuFragment 对应Android的SkuFragment.kt
struct SkuView: View {
    let selection: Selection
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack {
            // SKU列表标题
            Text("选择部件")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
            
            // SKU网格列表
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(selection.skus, id: \.id) { sku in
                        SkuItemView(
                            sku: sku,
                            isSelected: viewModel.isSkuSelected(sku.id),
                            onSelect: { viewModel.toggleSelectSku(sku) },
                            viewModel: viewModel
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color.black.opacity(0.9))
        .cornerRadius(16)
        .padding()
    }
}

// SkuItemView SKU项视图
struct SkuItemView: View {
    let sku: Sku
    let isSelected: Bool
    let onSelect: () -> Void
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                // SKU预览图片
                if let skinImage = viewModel.getSkinBitmap(skinName: sku.skinName) {
                    Image(uiImage: skinImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } else {
                    Color.gray
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
                // 选中状态指示器
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? Color.green : Color.gray, lineWidth: 2)
                        .frame(width: 20, height: 20)
                    if isSelected {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 12, height: 12)
                    }
                }
                .offset(y: -10)
                
                // 显示PRO标签
                if sku.pro > 0 {
                    Text("PRO")
                        .font(.caption)
                        .foregroundColor(.yellow)
                        .padding(2)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                        .offset(y: -10)
                }
            }
            .padding(4)
        }
    }
}

// 预览
struct SkuView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟数据
        let sku1 = Sku(id: "sku1", skinName: "skin1", category: "category1")
        let sku2 = Sku(id: "sku2", skinName: "skin2", category: "category1")
        let selection = Selection(id: "selection1", skus: [sku1, sku2])
        
        // 创建模拟视图模型
        let viewModel = SpineEditorViewModel()
        
        SkuView(selection: selection, viewModel: viewModel)
    }
}