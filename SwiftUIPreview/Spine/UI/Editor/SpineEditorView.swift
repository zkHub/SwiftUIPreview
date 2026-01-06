import SwiftUI
import UIKit

// SpineEditorView 主视图，对应Android的SpineEditorActivity.kt
struct SpineEditorView: View {
    // 视图模型
    @StateObject private var viewModel = SpineEditorViewModel()
    
    // 选择索引
    @State private var selectionIndex: Int = 0
    
    // 控制面板可见性
    @State private var showingControls: Bool = true
    
    // 初始化器
    init(templateId: String) {
        _ = viewModel
        viewModel.initialize(templateId: templateId)
    }
    
    var body: some View {
        ZStack {
            // 背景色
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // 主内容区域
            VStack {
                // 顶部栏
                TopBarView(onBack: { /* 返回操作 */ })
                    .zIndex(1)
                
                // 角色渲染区域
                Spacer()
                
                // 根据编辑器状态渲染内容
                switch viewModel.editorUiState {
                case .loading:
                    LoadingView()
                case .error:
                    ErrorView(onRetry: { viewModel.loadEditor() })
                case .loaded(let editor):
                    SpineCharacterView(editor: editor, avatar: $viewModel.avatar)
                }
                
                Spacer()
                
                // 底部控制面板
                if showingControls {
                    ControlPanelView(
                        onReset: { viewModel.resetAvatar() },
                        onRandom: { viewModel.randomAvatar() },
                        onUndo: { viewModel.undo() },
                        onRedo: { viewModel.redo() },
                        onDone: { viewModel.export() },
                        onPalette: { /* 显示调色板 */ },
                        canUndo: viewModel.canUndo,
                        canRedo: viewModel.canRedo,
                        showPalette: viewModel.showPalette
                    )
                    .zIndex(1)
                }
                
                // 选择面板
                SelectionPanelView(
                    selections: viewModel.editor?.template.selections ?? [],
                    selectionIndex: $selectionIndex,
                    viewModel: viewModel
                )
                .zIndex(1)
            }
            
            // 导出状态覆盖层
            if viewModel.exportUiState.isLoading {
                PrinterLoadingView()
            } else if let export = viewModel.exportUiState.export {
                PrinterEffectView(export: export) {
                    // 导出完成后的操作
                    print("Export completed: \(export.imageFile)")
                }
            }
        }
        // 监听选择索引变化，更新调色板可见性
        .onChange(of: selectionIndex) {
            viewModel.updatePaletteVisibility(selectionIndex: $0)
        }
    }
}

// 顶部栏视图
struct TopBarView: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            // 返回按钮
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            .padding()
            
            Spacer()
            
            // 标题
            Text("Spine Editor")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
            
            Spacer()
            
            // 占位符
            Rectangle()
                .frame(width: 44, height: 44)
                .foregroundColor(.clear)
                .padding()
        }
        .background(Color.black.opacity(0.8))
    }
}

// 加载视图
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
                .padding()
            Text("Loading...")
                .foregroundColor(.white)
                .font(.headline)
        }
    }
}

// 错误视图
struct ErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.red)
                .font(.system(size: 64))
                .padding()
            Text("Failed to load")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
            Button(action: onRetry) {
                Text("Retry")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
}

// Spine角色渲染视图
struct SpineCharacterView: View {
    let editor: Editor
    @Binding var avatar: Avatar
    
    var body: some View {
        ZStack {
            // 角色渲染区域
            SpineRenderView(skeletonDrawable: editor.skeletonDrawable)
                .frame(width: 300, height: 500)
                .background(Color.clear)
            
            // 显示选中的SKU和色调信息
            VStack {
                Spacer()
                Text("Selected SKUs: \(avatar.skus.count)")
                    .foregroundColor(.white)
                    .font(.caption)
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
            }
        }
    }
}

// Spine渲染视图（UIViewRepresentable）
struct SpineRenderView: UIViewRepresentable {
    let skeletonDrawable: SkeletonDrawable
    
    func makeUIView(context: Context) -> UIView {
        // 创建并配置Spine渲染视图
        let view = SpineUIView(frame: .zero, skeletonDrawable: skeletonDrawable)
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新视图
    }
    
    // 自定义UIView用于Spine渲染
    class SpineUIView: UIView {
        private let skeletonDrawable: SkeletonDrawable
        private let renderer = SkeletonRenderer()
        
        // 初始化器
        init(frame: CGRect, skeletonDrawable: SkeletonDrawable) {
            self.skeletonDrawable = skeletonDrawable
            super.init(frame: frame)
            
            // 设置动画
            if let animation = skeletonDrawable.skeletonData.findAnimation("idle_default") {
                skeletonDrawable.animationState.setAnimation(0, animation, true)
            }
            
            // 启动动画循环
            startAnimationLoop()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // 启动动画循环
        private func startAnimationLoop() {
            let displayLink = CADisplayLink(target: self, selector: #selector(update))
            displayLink.add(to: .main, forMode: .common)
        }
        
        // 动画更新方法
        @objc private func update(displayLink: CADisplayLink) {
            let deltaTime = displayLink.duration
            skeletonDrawable.update(deltaTime)
            setNeedsDisplay()
        }
        
        // 绘制方法
        override func draw(_ rect: CGRect) {
            guard let context = UIGraphicsGetCurrentContext() else { return }
            
            // 清除背景
            context.clear(rect)
            
            // 渲染骨骼
            renderer.render(skeleton: skeletonDrawable.skeleton, context: context)
        }
    }
}

// 控制面板视图
struct ControlPanelView: View {
    let onReset: () -> Void
    let onRandom: () -> Void
    let onUndo: () -> Void
    let onRedo: () -> Void
    let onDone: () -> Void
    let onPalette: () -> Void
    let canUndo: Bool
    let canRedo: Bool
    let showPalette: Bool
    
    var body: some View {
        HStack(spacing: 20) {
            // 重置按钮
            ControlButton(imageName: "arrow.clockwise", action: onReset, label: "重置")
            
            // 随机按钮
            ControlButton(imageName: "dice", action: onRandom, label: "随机")
            
            // 撤销按钮
            ControlButton(imageName: "arrow.uturn.left", action: onUndo, label: "撤销")
                .disabled(!canUndo)
            
            // 重做按钮
            ControlButton(imageName: "arrow.uturn.right", action: onRedo, label: "重做")
                .disabled(!canRedo)
            
            // 完成按钮
            ControlButton(imageName: "checkmark.circle", action: onDone, label: "完成")
                .foregroundColor(.green)
            
            // 调色板按钮
            if showPalette {
                ControlButton(imageName: "palette", action: onPalette, label: "调色")
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// 控制按钮视图
struct ControlButton: View {
    let imageName: String
    let action: () -> Void
    let label: String
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: imageName)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(8)
        }
    }
}

// 选择面板视图
struct SelectionPanelView: View {
    let selections: [Selection]
    @Binding var selectionIndex: Int
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(0..<selections.count, id: \.self) { index in
                    SelectionItemView(
                        selection: selections[index],
                        isSelected: index == selectionIndex,
                        onSelect: { selectionIndex = index },
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal)
        }
        .background(Color.black.opacity(0.8))
        .frame(height: 120)
    }
}

// 选择项视图
struct SelectionItemView: View {
    let selection: Selection
    let isSelected: Bool
    let onSelect: () -> Void
    let viewModel: SpineEditorViewModel
    
    var body: some View {
        Button(action: onSelect) {
            VStack {
                // 封面图片
                if let coverUrl = selection.coverUrl.url {
                    AsyncImage(url: coverUrl) {image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    } placeholder: {
                        Color.gray
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                    }
                } else {
                    Color.gray
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
                
                // 选中状态指示器
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(isSelected ? .green : .gray)
                    .offset(y: -10)
            }
        }
    }
}

// 加载视图
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(2)
            Text("Loading...")
                .foregroundColor(.white)
                .font(.headline)
                .padding()
        }
    }
}

// 打印加载视图
struct PrinterLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(2)
                Text("Exporting...")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            }
        }
    }
}

// 打印效果视图
struct PrinterEffectView: View {
    let export: Export
    let onCompleted: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Export Complete")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                
                // 显示导出的图片
                Image(uiImage: UIImage(contentsOfFile: export.imageFile.path) ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .cornerRadius(8)
                
                Button(action: onCompleted) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
    }
}

// 扩展String，添加URL转换方法
extension String {
    var url: URL? {
        return URL(string: self)
    }
}

// 预览
struct SpineEditorView_Previews: PreviewProvider {
    static var previews: some View {
        SpineEditorView(templateId: "template1")
    }
}
