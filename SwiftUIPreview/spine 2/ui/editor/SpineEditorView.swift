import SwiftUI
import Spine

/// Spine 编辑器主视图，对应 Android 的 SpineEditorActivity
struct SpineEditorView: View {
    let templateId: String
    let portal: String
    
    @StateObject private var viewModel = SpineEditorViewModel()

    @State private var currentSelectionIndex: Int = 0
    @State private var showingToning: Bool = false
    
    var body: some View {
        ZStack {
            if viewModel.editorUiState.isLoading {
                LoadingView()
            } else if viewModel.editorUiState.isError {
                ErrorView(onRetry: {
                    viewModel.loadEditor()
                })
            } else {
                mainContent
            }
        }
        .onAppear {
            viewModel.initialize(templateId: templateId)
        }
        .environmentObject(viewModel)
    }
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // 顶部控制栏
            topBar
            
            // Avatar 显示区域
            avatarContainer
            
            // 底部面板
            bottomPanel
        }
        .background(Color.black)
    }
    
    private var topBar: some View {
        HStack {
            Button(action: {
                // 返回
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.title2)
            }
            
            Spacer()
            
            // 控制按钮
            HStack(spacing: 16) {
                Button(action: {
                    viewModel.resetAvatar()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    viewModel.randomAvatar()
                }) {
                    Image(systemName: "shuffle")
                        .foregroundColor(.white)
                }
                
                Button(action: {
                    viewModel.undo()
                }) {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(viewModel.canUndo ? .white : .gray)
                }
                .disabled(!viewModel.canUndo)
                
                Button(action: {
                    viewModel.redo()
                }) {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(viewModel.canRedo ? .white : .gray)
                }
                .disabled(!viewModel.canRedo)
                
                if viewModel.showPalette {
                    Button(action: {
                        showingToning.toggle()
                    }) {
                        Image(systemName: "paintpalette")
                            .foregroundColor(showingToning ? .blue : .white)
                    }
                }
                
                // 完成按钮
                Button(action: {
                    done()
                }) {
                    HStack {
//                        if viewModel.avatar.skus.contains(where: { skuId in
//                            viewModel.editor?.template.selections
//                                .flatMap { $0.skus }
//                                .first { $0.id == skuId }?.pro ?? 0 > 0
//                        }) {
//                            Text("\(viewModel.avatar.skus.filter { skuId in
//                                viewModel.editor?.template.selections
//                                    .flatMap { $0.skus }
//                                    .first { $0.id == skuId }?.pro ?? 0 > 0
//                            }.count)")
//                                .font(.caption)
//                                .foregroundColor(.white)
//                                .padding(4)
//                                .background(Color.red)
//                                .clipShape(Circle())
//                        }
                        Text("完成")
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
    
    private var avatarContainer: some View {
        ZStack {
            if let editor = viewModel.editor {
                SpineAvatarView(
                    template: editor.template,
                    skuSlots: editor.skuSlots
                )
            }
        }
        .aspectRatio(1.0, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var bottomPanel: some View {
        VStack(spacing: 0) {
            if showingToning {
                ToningView(
                    selectionIndex: currentSelectionIndex
                )
                .transition(.move(edge: .bottom))
            } else {
                SelectionView(
                    selectionIndex: $currentSelectionIndex
                )
            }
        }
//        .frame(height: 300)
        .background(Color.black.opacity(0.9))
    }
    
    private func done() {
        // 显示导出效果
        viewModel.export()
    }
}

/// 加载视图
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
            Text("加载中...")
                .foregroundColor(.white)
                .padding(.top)
        }
    }
}

/// 错误视图
struct ErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text("加载失败")
                .foregroundColor(.white)
                .padding()
            Button("重试", action: onRetry)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
    }
}

/// Spine Avatar 视图（用于显示和更新 Avatar）
struct SpineAvatarView: View {
    let template: TemplateConfig
    let skuSlots: [String: Set<String>]
    
    @EnvironmentObject var viewModel: SpineEditorViewModel
        
    var body: some View {
        Group {
            if let drawable = viewModel.drawable {
                SpineView(
                    from: .drawable(drawable),
                    controller: viewModel.controller,
                    mode: .fit,
                    alignment: .center,
                    boundsProvider: RawBounds(x: -256, y: -512, width: 512, height: 512),
                    backgroundColor: .white
                )
                .aspectRatio(1.0, contentMode: .fit)
                .onAppear {
                    applyAvatar(controller: viewModel.controller)
                }
                .onChange(of: viewModel.avatar) { _ in
                    // 使用捕获列表避免潜在的循环引用
                    applyAvatar(controller: viewModel.controller)
                }

            } else {
                Color.clear
            }
        }
    }
    
    private func applyAvatar(controller: SpineController) {
        guard let drawable = viewModel.drawable else {
            return
        }
        let skeleton = drawable.skeleton
        
        // 应用皮肤
        let skus = template.selections
            .flatMap { $0.skus }
            .filter { viewModel.avatar.skus.contains($0.id) }
        
        // 构建自定义皮肤
        // 注意：每次创建新的 skin，旧的会被自动释放
        let customSkin = Skin.create(name: "avatar-skin")
        for sku in skus {
            if let skin = drawable.skeletonData.findSkin(name: sku.skinName) {
                customSkin.addSkin(other: skin)
            }
        }
        
        skeleton.skin = customSkin
        skeleton.setToSetupPose()
        
        // 应用颜色
        applyColor(skeleton: skeleton)
        
        // 播放动画
        playAnimation(controller: controller, animationName: "react_default")
    }
    
    private func applyColor(skeleton: Skeleton) {
        // 重置颜色
        resetColor(skeleton: skeleton)
        
        // 应用染色
        guard let avatarTonings = viewModel.avatar.tonings, !avatarTonings.isEmpty else { return }
        
        let tonings = template.tonings ?? []
        guard !tonings.isEmpty else { return }
        
        // 构建 skuId -> Sku 的映射
        let allSkusMap = template.selections
            .flatMap { $0.skus }
            .reduce(into: [String: Sku]()) { $0[$1.id] = $1 }
        
        let selectedSkuIds = Set(viewModel.avatar.skus)
        
        for (toningId, colorId) in avatarTonings {
            guard let toning = tonings.first(where: { $0.id == toningId }),
                  let colorSet = toning.colors.first(where: { $0.id == colorId }) else {
                continue
            }
            
            // 计算颜色
            let sampler = ColorSampler(colors: colorSet.colors)
            let lightColor = sampler.bright()
            let darkColor = sampler.dark()
            
            // 找到所有符合条件的 SKU
            let affectedSkus = selectedSkuIds.compactMap { skuId -> Sku? in
                guard let sku = allSkusMap[skuId],
                      sku.toningIds?.contains(toningId) == true else {
                    return nil
                }
                return sku
            }
            
            // 对所有受影响的 SKU 的 Slots 染色
            for sku in affectedSkus {
                guard let slots = skuSlots[sku.id] else { continue }
                for slotName in slots {
                    if let slot = skeleton.findSlot(slotName: slotName) {
                        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
                        lightColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                        slot.setColor(r: Float(r), g: Float(g), b: Float(b), a: Float(a))
                        
                        if slot.hasDarkColor() {
                            darkColor.getRed(&r, green: &g, blue: &b, alpha: &a)
                            slot.setDarkColor(r: Float(r), g: Float(g), b: Float(b), a: Float(a))
                        }
                    }
                }
            }
        }
    }
    
    private func resetColor(skeleton: Skeleton) {
        for slot in skeleton.slots {
            slot.setColor(r: 1, g: 1, b: 1, a: 1)
            if slot.hasDarkColor() {
                slot.setDarkColor(r: 1, g: 1, b: 1, a: 1)
            }
        }
    }
    
    private func playAnimation(controller: SpineController, animationName: String) {
//        guard let animation = drawable.skeletonData.findAnimation(name: animationName) else {
//            return
//        }
//        
//        controller.animationState.setAnimation(trackIndex: 0, animation: animation, loop: false)
//        
//        // 添加 idle 动画
//        if let idle = drawable.skeletonData.findAnimation(name: "idle_default") {
//            controller.animationState.addAnimation(trackIndex: 0, animation: idle, loop: true, delay: 0)
//        }
    }
}

