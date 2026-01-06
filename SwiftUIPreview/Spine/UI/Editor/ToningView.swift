import SwiftUI

// ToningFragment 对应Android的ToningFragment.kt
struct ToningView: View {
    let selectionIndex: Int
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack {
            // 调色板标题
            Text("调色板")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
            
            // 色调列表
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(viewModel.getToningSets(selectionIndex: selectionIndex), id: \.sku.id) {
                        toningSet in
                        ToningSectionView(toningSet: toningSet, viewModel: viewModel)
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

// ToningSectionFragment 对应Android的ToningSectionFragment.kt
struct ToningSectionView: View {
    let toningSet: ToningSet
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 色调组标题
            Text(toningSet.sku.skinName)
                .foregroundColor(.white)
                .font(.subheadline)
            
            // 色调选项
            VStack(spacing: 12) {
                ForEach(toningSet.tonings, id: \.id) {
                    toning in
                    ToningItemView(toning: toning, viewModel: viewModel)
                }
            }
        }
    }
}

// ToningItemView 色调项视图
struct ToningItemView: View {
    let toning: Toning
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 色调名称
            if let name = toning.name {
                Text(name)
                    .foregroundColor(.white)
                    .font(.caption)
            }
            
            // 颜色集横向滚动
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(toning.colors, id: \.id) { colorSet in
                        ColorSetItemView(
                            toningId: toning.id,
                            colorSet: colorSet,
                            isSelected: viewModel.isColorSelected(toningId: toning.id, colorId: colorSet.id),
                            onSelect: { viewModel.selectColor(toningId: toning.id, colorId: colorSet.id) }
                        )
                    }
                }
            }
        }
    }
}

// ColorSetItemView 颜色集项视图
struct ColorSetItemView: View {
    let toningId: String
    let colorSet: ColorSet
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                // 颜色预览
                HStack(spacing: 2) {
                    ForEach(colorSet.colors, id: \.offset) {
                        color in
                        Rectangle()
                            .frame(width: 20, height: 40)
                            .foregroundColor(color.uiColor)
                    }
                }
                .cornerRadius(4)
                
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
            }
        }
    }
}

// 预览
struct ToningView_Previews: PreviewProvider {
    static var previews: some View {
        // 创建模拟数据
        let color1 = Color(color: "#FF0000", offset: 0.0)
        let color2 = Color(color: "#00FF00", offset: 0.5)
        let color3 = Color(color: "#0000FF", offset: 1.0)
        
        let colorSet1 = ColorSet(id: "colorSet1", colors: [color1, color2, color3])
        let colorSet2 = ColorSet(id: "colorSet2", colors: [color3, color2, color1])
        
        let toning1 = Toning(id: "toning1", name: "红色系", colors: [colorSet1, colorSet2])
        let toning2 = Toning(id: "toning2", name: "蓝色系", colors: [colorSet2, colorSet1])
        
        let sku = Sku(id: "sku1", skinName: "skin1", category: "category1", toningIds: ["toning1", "toning2"])
        let toningSet = ToningSet(sku: sku, tonings: [toning1, toning2])
        
        // 创建模拟视图模型
        let viewModel = SpineEditorViewModel()
        
        ToningView(selectionIndex: 0, viewModel: viewModel)
    }
}