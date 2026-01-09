import Foundation
import UIKit
import Combine
import Spine
import SpineCppLite


/// 编辑器 UI 状态，对应 Android 的 EditorUiState
struct EditorUiState {
    var isLoading: Bool = false
    var isError: Bool = false
    var editor: SpineEditorConfig? = nil
}

/// 导出 UI 状态，对应 Android 的 ExportUiState
struct ExportUiState {
    var isLoading: Bool = false
    var export: Export? = nil
}

/// Spine 编辑器 ViewModel，对应 Android 的 SpineEditorViewModel.kt
//@MainActor
class SpineEditorViewModel: ObservableObject {
    var templateId: String = ""
    
    @Published var controller: SpineController
    @Published var drawable: SkeletonDrawableWrapper?
    
    @Published var editorUiState = EditorUiState()
    @Published var avatar = SpineAvatar()
    @Published var canUndo = false
    @Published var canRedo = false
    @Published var showPalette = false
    @Published var exportUiState = ExportUiState()
    
    private var isInitialized = false
    let thumbnailSize = CGSize(width: 200, height: 200)

    var editor: SpineEditorConfig? {
        editorUiState.editor
    }
    
    private var history: [SpineAvatar] = []
    private var historyIndex: Int = -1
    private let maxHistorySize = 50
    
    // Task 引用，用于取消异步操作
    private var loadTask: Task<Void, Never>?
    private var exportTask: Task<Void, Never>?
    
    
    init() {
        controller = SpineController(
            onInitialized: { controller in
                // 默认播放 idle 动画
                if let animation = controller.skeletonData.findAnimation(name: "idle_default") {
                    controller.animationState.setAnimation(trackIndex: 0, animation: animation, loop: true)
                }
            },
            disposeDrawableOnDeInit: false
        )
    }
    
    
    /// 初始化，对应 Android 的 initialize
    func initialize(templateId: String) {
        guard !isInitialized else { return }
        isInitialized = true
        self.templateId = templateId
        loadEditor()
    }
    
    deinit {
        // 取消所有正在运行的 Task，防止内存泄漏
        loadTask?.cancel()
        exportTask?.cancel()

        // 释放 Spine 资源
        drawable?.dispose()
    }
    
    /// 加载编辑器，对应 Android 的 loadEditor
    func loadEditor() {
        // 取消之前的加载任务
        loadTask?.cancel()
        
        editorUiState = EditorUiState(isLoading: true, isError: false)
        
        loadTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let editor = try await self.loadEditorAsync()
                
                // 检查任务是否被取消
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.editorUiState = EditorUiState(
                        isLoading: false,
                        isError: false,
                        editor: editor
                    )
                    
                    // 如果有初始 Avatar，设置它
                    if let initAvatar = editor.template.initAvatar {
                        self.setupInitAvatar(initAvatar)
                    }
                }
            } catch {
                // 如果任务被取消，不更新状态
                guard !Task.isCancelled else { return }
                
                print("❌ [SpineEditorViewModel] 加载编辑器失败: \(error)")
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.editorUiState = EditorUiState(isLoading: false, isError: true)
                }
            }
        }
    }
    
    /// 异步加载编辑器
    @MainActor
    private func loadEditorAsync() async throws -> SpineEditorConfig {
        return try await Task.detached(priority: .high) { [weak self] in
            guard let self = self else {
                throw CancellationError()
            }
            
            // 检查任务是否被取消
            try Task.checkCancellation()
            
            // 加载 Template
            let template = try self.getTemplate(templateId: self.templateId)
            
            // 检查任务是否被取消
            try Task.checkCancellation()
            
            // 加载 SkeletonDrawable
            let drawable = try await self.getSkeletonDrawable(templateId: self.templateId)
            
            // 检查任务是否被取消
            try Task.checkCancellation()
            
            // 获取皮肤缩略图
            let skeletonSkins = try await self.getSkeletonSkins(drawable: drawable)
            
            // 检查任务是否被取消
            try Task.checkCancellation()
            
            // 获取 SKU Slots 映射
            let skeletonSlots = self.getSkeletonSlots(drawable: drawable, template: template)
            
            // 排序 selections
            let sortedSelections = template.selections.sorted { $0.playIndex < $1.playIndex }
            let sortedTemplate = TemplateConfig(
                selections: sortedSelections,
                tonings: template.tonings,
                animations: template.animations,
                requireCategories: template.requireCategories,
                initAvatar: template.initAvatar
            )
            await MainActor.run {
                self.drawable = drawable
            }
            return SpineEditorConfig(
                template: sortedTemplate,
//                skeletonDrawable: drawable,
                skeletonSkins: skeletonSkins,
                skuSlots: skeletonSlots
            )
        }.value
    }
    
    /// 获取 Template，对应 Android 的 getTemplate
    private func getTemplate(templateId: String) throws -> TemplateConfig {
        guard let bundle = Bundle.main.path(forResource: "\(templateId)", ofType: "json") else {
            throw NSError(domain: "SpineEditorViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到模板文件"])
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: bundle))
        return try JSONDecoder().decode(TemplateConfig.self, from: data)
    }
    
    /// 获取 SkeletonDrawable，对应 Android 的 getSkeletonDrawable
    private func getSkeletonDrawable(templateId: String) async throws -> SkeletonDrawableWrapper {
        guard let atlasPath = Bundle.main.path(forResource: "spine-\(templateId)", ofType: "atlas"),
              let skeletonPath = Bundle.main.path(forResource: "spine-\(templateId)", ofType: "json") else {
            throw NSError(domain: "SpineEditorViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到 Spine 资源文件"])
        }
        
        let atlasURL = URL(fileURLWithPath: atlasPath)
        let skeletonURL = URL(fileURLWithPath: skeletonPath)
        
        return try await SkeletonDrawableWrapper.fromFile(atlasFile: atlasURL, skeletonFile: skeletonURL)
    }
    
    /// 设置初始 Avatar，对应 Android 的 setupInitAvatar
    private func setupInitAvatar(_ initAvatar: SpineAvatar) {
        avatar = initAvatar
        history.removeAll()
        history.append(initAvatar)
        historyIndex = 0
        updateUndoRedoState()
    }
    
    /// 选择 SKU，对应 Android 的 selectSku
    func selectSku(_ sku: Sku) {
        guard let editor = editor else { return }
        
        var currentSkus = avatar.skus
        
        // 构建 skuId -> Sku 的映射
        let allSkusMap = editor.template.selections
            .flatMap { $0.skus }
            .reduce(into: [String: Sku]()) { $0[$1.id] = $1 }
        
        // 找到当前已选中的同 category 的 SKU
        if let existingSkuId = currentSkus.first(where: { allSkusMap[$0]?.category == sku.category }),
           existingSkuId != sku.id {
            // 替换同 category 的 SKU
            if let index = currentSkus.firstIndex(of: existingSkuId) {
                currentSkus[index] = sku.id
            }
        } else if !currentSkus.contains(sku.id) {
            // 添加新 SKU
            currentSkus.append(sku.id)
        }
        
        let newAvatar = SpineAvatar(
            version: avatar.version,
            skus: currentSkus,
            animation: avatar.animation, tonings: avatar.tonings
        )
        updateAvatar(newAvatar)
    }
    
    /// 取消选择 SKU，对应 Android 的 unselectSku
    func unselectSku(_ sku: Sku) {
        guard let editor = editor else { return }
        
        // 检查是否是必选的 category
        let requireCategories = editor.template.requireCategories ?? []
        if requireCategories.contains(sku.category) {
            // 必选 category 不能取消选择
            return
        }
        
        var selectedSkus = avatar.skus
        selectedSkus.removeAll { $0 == sku.id }
        
        let newAvatar = SpineAvatar(
            version: avatar.version,
            skus: selectedSkus,
            animation: avatar.animation, tonings: avatar.tonings
        )
        updateAvatar(newAvatar)
    }
    
    /// 检查 SKU 是否已选中，对应 Android 的 isSkuSelected
    func isSkuSelected(skuId: String) -> Bool {
        return avatar.skus.contains(skuId)
    }
    
    /// 切换 SKU 选择状态，对应 Android 的 toggleSelectSku
    func toggleSelectSku(_ sku: Sku) {
        if isSkuSelected(skuId: sku.id) {
            unselectSku(sku)
        } else {
            selectSku(sku)
        }
    }
    
    /// 选择颜色，对应 Android 的 selectColor
    func selectColor(toningId: String, colorId: String) {
        var selectedTonings = avatar.tonings
        if selectedTonings[toningId] == colorId {
            selectedTonings.removeValue(forKey: toningId)
        } else {
            selectedTonings[toningId] = colorId
        }
        
        let newAvatar = SpineAvatar(
            version: avatar.version,
            skus: avatar.skus,
            animation: avatar.animation, tonings: selectedTonings
        )
        updateAvatar(newAvatar)
    }
    
    /// 检查颜色是否已选中，对应 Android 的 isColorSelected
    func isColorSelected(toningId: String, colorId: String) -> Bool {
        return avatar.tonings[toningId] == colorId
    }
    
    /// 获取皮肤缩略图，对应 Android 的 getSkinBitmap
    func getSkinBitmap(skinName: String) -> UIImage? {
        return editor?.skeletonSkins[skinName]
    }
    
    /// 重置 Avatar，对应 Android 的 resetAvatar
    func resetAvatar() {
        guard let initAvatar = editor?.template.initAvatar,
              avatar != initAvatar else {
            return
        }
        updateAvatar(initAvatar)
    }
    
    /// 随机 Avatar，对应 Android 的 randomAvatar
    func randomAvatar() {
        guard let editor = editor else { return }
        let template = editor.template
        
        // 构建 Category -> SKUs 的索引
        let categoryToSkus = buildCategoryToSkusMap(template: template)
        
        // 选择 SKU
        var selectedSkus = Set<String>()
        
        // 阶段1：处理必选 Categories（100%概率）
        let requireCategories = template.requireCategories ?? []
        for requiredCategory in requireCategories {
            if let candidates = categoryToSkus[requiredCategory], !candidates.isEmpty {
                if let selectedSku = candidates.randomElement() {
                    selectedSkus.insert(selectedSku.id)
                }
            }
        }
        
        // 阶段2：处理可选 Categories（60%概率）
        let allCategories = Set(categoryToSkus.keys)
        let optionalCategories = allCategories.subtracting(Set(requireCategories))
        
        for optionalCategory in optionalCategories {
            if Double.random(in: 0..<1) < 0.6 {
                if let candidates = categoryToSkus[optionalCategory], !candidates.isEmpty {
                    if let selectedSku = candidates.randomElement() {
                        selectedSkus.insert(selectedSku.id)
                    }
                }
            }
        }
        
        // Step 3: 随机染色（40%概率）
        let randomTonings = generateRandomTonings(selectedSkuIds: selectedSkus, template: template)
        
        // 生成新 Avatar（清空染色）
        let newAvatar = SpineAvatar(
            version: avatar.version,
            skus: Array(selectedSkus),
            animation: avatar.animation, tonings: randomTonings
        )
        updateAvatar(newAvatar)
    }
    
    
    /**
     * 生成随机染色配置
     * 对于每个支持染色的 toningId，有 40% 概率随机选择一个颜色
     */
    func generateRandomTonings(selectedSkuIds: Set<String>, template: TemplateConfig) -> [String: String] {
        var randomTonings: [String: String] = [:]
        // 1. 构建 skuId -> Sku 映射
        let allSkusMap: [String: Sku] = template.selections
            .flatMap { $0.skus }
            .reduce(into: [String: Sku]()) { dict, sku in
                dict[sku.id] = sku
            }
        
        // 2. 收集所有可用的 toningIds（去重）
        var availableToningIds = Set<String>()
        for skuId in selectedSkuIds {
            if let sku = allSkusMap[skuId], let toningIds = sku.toningIds {
                availableToningIds.formUnion(toningIds)
            }
        }
        
        // 如果 template.tonings 为空就返回空字典
        guard let allTonings = template.tonings else {
            return [:]
        }
        
        // 3. 对每个 toningId 随机选择一个颜色
        for toningId in availableToningIds {
            if let toning = allTonings.first(where: { $0.id == toningId }),
               !toning.colors.isEmpty {
                
                if let randomColor = toning.colors.randomElement() {
                    randomTonings[toningId] = randomColor.id
                }
            }
        }

        return randomTonings
    }
    
    
    /// 构建 Category -> SKUs 的索引映射，对应 Android 的 buildCategoryToSkusMap
    private func buildCategoryToSkusMap(template: TemplateConfig) -> [String: [Sku]] {
        var categoryToSkus: [String: [Sku]] = [:]
        
        for selection in template.selections {
            for sku in selection.skus {
                if categoryToSkus[sku.category] == nil {
                    categoryToSkus[sku.category] = []
                }
                categoryToSkus[sku.category]?.append(sku)
            }
        }
        
        return categoryToSkus
    }
    
    /// 撤销，对应 Android 的 undo
    func undo() {
        guard canUndo else { return }
        historyIndex -= 1
        if historyIndex >= 0 && historyIndex < history.count {
            avatar = history[historyIndex]
            updateUndoRedoState()
        }
    }
    
    /// 重做，对应 Android 的 redo
    func redo() {
        guard canRedo else { return }
        historyIndex += 1
        if historyIndex < history.count {
            avatar = history[historyIndex]
            updateUndoRedoState()
        }
    }
    
    /// 更新撤销/重做状态，对应 Android 的 updateUndoRedoState
    private func updateUndoRedoState() {
        canUndo = historyIndex > 0
        canRedo = historyIndex < history.count - 1
    }
    
    /// 更新 Avatar，对应 Android 的 updateAvatar
    private func updateAvatar(_ newAvatar: SpineAvatar) {
        // 如果当前不在历史记录末尾，删除后面的记录
        if historyIndex < history.count - 1 {
            history.removeSubrange((historyIndex + 1)..<history.count)
        }
        
        history.append(newAvatar)
        if history.count > maxHistorySize {
            history.removeFirst()
        } else {
            historyIndex += 1
        }
        
        avatar = newAvatar
        updateUndoRedoState()
    }
    
    func applyAvatar() {
        guard let drawable = drawable, let template = editor?.template else {
            return
        }
        let skeleton = drawable.skeleton
        
        // 应用皮肤
        let skus = template.selections
            .flatMap { $0.skus }
            .filter { avatar.skus.contains($0.id) }
        
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
        guard let skuSlots = editor?.skuSlots, let template = editor?.template else {
            return
        }
        // 重置颜色
        resetColor(skeleton: skeleton)
        
        // 应用染色
        let avatarTonings = avatar.tonings
        guard !avatarTonings.isEmpty else { return }
        
        let tonings = template.tonings ?? []
        guard !tonings.isEmpty else { return }
        
        // 构建 skuId -> Sku 的映射
        let allSkusMap = template.selections
            .flatMap { $0.skus }
            .reduce(into: [String: Sku]()) { $0[$1.id] = $1 }
        
        let selectedSkuIds = Set(avatar.skus)
        
        for (toningId, colorId) in avatarTonings {
            guard let toning = tonings.first(where: { $0.id == toningId }),
                  let colorSet = toning.colors.first(where: { $0.id == colorId }) else {
                continue
            }
            
            // 计算颜色
            var lightColor = UIColor(hexRGB: colorSet.light)
            let darkColor = UIColor(hexRGB: colorSet.dark)
            if (lightColor == UIColor.black) {
                lightColor = darkColor
            }
            
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
        guard let drawable = drawable, let animation = drawable.skeletonData.findAnimation(name: animationName) else {
            return
        }
        
        drawable.animationState.setAnimation(trackIndex: 0, animation: animation, loop: false)
        
        // 添加 idle 动画
        if let idle = drawable.skeletonData.findAnimation(name: "idle_default") {
            drawable.animationState.addAnimation(trackIndex: 0, animation: idle, loop: true, delay: 0)
        }
    }
    
    
    
    /// 导出，对应 Android 的 export
    func export() {
        guard let editor = editor else { return }
        
        // 取消之前的导出任务
        exportTask?.cancel()
        
        exportUiState = ExportUiState(isLoading: true, export: nil)
        
        exportTask = Task { [weak self] in
            guard let self = self else { return }
            
            do {
                let export = try await self.exportAsync(editor: editor)
                
                // 检查任务是否被取消
                guard !Task.isCancelled else { return }
                
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.exportUiState = ExportUiState(isLoading: false, export: export)
                }
            } catch {
                // 如果任务被取消，不更新状态
                guard !Task.isCancelled else { return }
                
                print("❌ [SpineEditorViewModel] 导出失败: \(error)")
                await MainActor.run {
                    guard !Task.isCancelled else { return }
                    self.exportUiState = ExportUiState(isLoading: false, export: nil)
                }
            }
        }
    }
    
    /// 异步导出
    private func exportAsync(editor: SpineEditorConfig) async throws -> Export {
        // 检查任务是否被取消
        try Task.checkCancellation()
        
//        let recorder = SpineRecorder(drawable: editor.skeletonDrawable)
        let fileName = "\(Int64(Date().timeIntervalSince1970 * 1000)).gif"
        
        // 创建临时文件
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // 录制 GIF（内部会确保在主线程执行渲染）
        try await recordGif(animationName: "idle_default", output: fileURL)
        
        // 检查任务是否被取消
        try Task.checkCancellation()
        
        return Export(avatar: self.avatar, imageFile: fileURL)
    }
    
    /// 更新调色板可见性，对应 Android 的 updatePaletteVisibility
    func updatePaletteVisibility(selectionIndex: Int) {
        guard let editor = editor else { return }
        let selections = editor.template.selections
        guard selectionIndex >= 0 && selectionIndex < selections.count else { return }
        
        let currentSelection = selections[selectionIndex]
        let selectedSkus = Set(avatar.skus)
        
        let isSupport = currentSelection.skus
            .filter { selectedSkus.contains($0.id) }
            .contains { !($0.toningIds?.isEmpty ?? true) }
        
        showPalette = isSupport
    }
    
    /// 获取调色方案集合，对应 Android 的 getToningSets
    func getToningSets(selectionIndex: Int) -> [ToningSet] {
        guard let editor = editor else { return [] }
        let selections = editor.template.selections
        guard selectionIndex >= 0 && selectionIndex < selections.count else { return [] }
        
        let currentSelection = selections[selectionIndex]
        let selectedSkus = Set(avatar.skus)
        let allTonings = editor.template.tonings ?? []
        
        return currentSelection.skus
            .filter { sku in
                selectedSkus.contains(sku.id) && !(sku.toningIds?.isEmpty ?? true)
            }
            .compactMap { sku in
                let tonings = (sku.toningIds ?? []).compactMap { toningId in
                    allTonings.first { $0.id == toningId }
                }
                
                if !tonings.isEmpty {
                    return ToningSet(sku: sku, tonings: tonings)
                } else {
                    return nil
                }
            }
    }
    
    
    /// 录制 GIF，对应 Android 的 recordGif
    @MainActor
    func recordGif(
        animationName: String,
        width: Int = 512,
        height: Int = 512,
        fps: Int = 30,
        output: URL
    ) async throws {
        guard let drawable = drawable, let animation = drawable.skeletonData.findAnimation(name: animationName) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到动画: \(animationName)"])
        }
        
        let duration = animation.duration
        let frameCount = max(2, Int(duration * Float(fps)))
        let delta = 1.0 / Float(fps)
        
        // 获取 skeleton 实例
        let skeleton = drawable.skeleton
        
        // 收集所有帧
        var frames: [UIImage] = []
        
        // 在主线程批量完成所有帧的渲染，尽量减少对显示动画的影响时间
        try await MainActor.run {
            // 渲染每一帧
            for frameIndex in 0..<frameCount {
                // 重置 skeleton 到初始姿态（每帧都重置，确保状态一致）
                skeleton.setToSetupPose()
                applyColor(skeleton: skeleton)
                // 计算当前应该渲染的动画时间（循环播放）
                let currentTime = Float(frameIndex) * delta
                let animationTime = currentTime.truncatingRemainder(dividingBy: duration)
                
                // 临时设置动画并应用到特定时间
                // 注意：这会短暂影响显示的动画，但我们快速完成所有帧后立即恢复
                drawable.animationState.setAnimation(trackIndex: 0, animation: animation, loop: false)
                
                // 更新到目标时间点
                // 使用小步长更新，确保动画正确应用
                var accumulatedTime: Float = 0
                let stepSize: Float = 0.016 // 约 60fps 的步长
                while accumulatedTime < animationTime {
                    let step = min(stepSize, animationTime - accumulatedTime)
                    drawable.animationState.update(delta: step)
                    accumulatedTime += step
                }
                
                drawable.animationState.apply(skeleton: skeleton)
                
                // 更新骨架变换
                skeleton.update(delta: 0)
                skeleton.updateWorldTransform(physics: SPINE_PHYSICS_UPDATE)
                
                // 渲染 skeleton 为 UIImage
                // 使用透明背景，避免背景出现在 GIF 中
                if let cgImage = try drawable.renderToImage(
                    size: CGSize(width: width, height: height),
                    boundsProvider: RawBounds(x: -256, y: -512, width: 512, height: 512),
                    backgroundColor: .clear, // 使用透明背景
                    scaleFactor: 1.0
                ) {
                    frames.append(UIImage(cgImage: cgImage))
                }
            }
            
            // 所有帧渲染完成后，立即恢复显示的动画
            // 恢复默认的 idle 动画
            if let idleAnimation = drawable.skeletonData.findAnimation(name: "idle_default") {
                drawable.animationState.setAnimation(trackIndex: 0, animation: idleAnimation, loop: true)
            }
        }
        
        // 将 frames 编码为 GIF
        try encodeFramesToGif(frames: frames, output: output, delay: 1000 / fps)
    }
    
    /// 将帧编码为 GIF
    private func encodeFramesToGif(frames: [UIImage], output: URL, delay: Int) throws {
        guard !frames.isEmpty else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "没有可编码的帧"])
        }
        
        // 使用 ImageIO 创建 GIF
        guard let destination = CGImageDestinationCreateWithURL(output as CFURL, "com.compuserve.gif" as CFString, frames.count, nil) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建 GIF 目标"])
        }
        
        // 设置全局 GIF 属性（无限循环）
        let globalGifProperties: [String: Any] = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFLoopCount as String: 0 // 无限循环
            ]
        ]
        CGImageDestinationSetProperties(destination, globalGifProperties as CFDictionary)
        
        // 设置每帧的延迟时间
        let delayTime = Double(delay) / 1000.0
        
        // 添加每一帧
        for frame in frames {
            guard let cgImage = frame.cgImage else { continue }
            
            let frameProperties: [String: Any] = [
                kCGImagePropertyGIFDictionary as String: [
                    kCGImagePropertyGIFDelayTime as String: delayTime
                ]
            ]
            
            CGImageDestinationAddImage(destination, cgImage, frameProperties as CFDictionary)
        }
        
        // 完成编码
        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "SpineRecorder", code: -1, userInfo: [NSLocalizedDescriptionKey: "GIF 编码失败"])
        }
    }
    
    
    /// 获取所有皮肤的缩略图，对应 Android 的 getSkeletonSkins
    @MainActor
    func getSkeletonSkins(drawable: SkeletonDrawableWrapper) async throws -> [String: UIImage] {
        return try await MainActor.run {
            var skeletonSkins: [String: UIImage] = [:]
            for skin in drawable.skeletonData.skins {
                if skin.name == "default" { continue }
                let skeleton = drawable.skeleton
                skeleton.skin = skin
                skeleton.setToSetupPose()
                skeleton.update(delta: 0)
                skeleton.updateWorldTransform(physics: SPINE_PHYSICS_UPDATE)
                try skin.name.flatMap { skinName in
                    if let img = try drawable.renderToImage(
                        size: CGSizeMake(200, 200),
                        backgroundColor: .white,
                        scaleFactor: UIScreen.main.scale
                    ) {
                        skeletonSkins[skinName] = UIImage(cgImage: img)
                    }
                }
            }
            return skeletonSkins
        }
    }
    
    /// 获取 SKU 对应的 Slot 名称集合，对应 Android 的 getSkeletonSlots
    func getSkeletonSlots(drawable: SkeletonDrawableWrapper, template: TemplateConfig) -> [String: Set<String>] {
        var mapping: [String: Set<String>] = [:]
        for selection in template.selections {
            for sku in selection.skus {
                guard let skin = drawable.skeletonData.findSkin(name: sku.skinName) else { continue }
                
                var slotNames = Set<String>()
                // 通过 skin 的 attachments 来获取 slot 名称
                for slot in drawable.skeletonData.slots {
                    if let _ = skin.getAttachment(slotIndex: slot.index, name: slot.name)?.name {
                        slotNames.insert(slot.name!)
                    }
                }
                mapping[sku.id] = slotNames
            }
        }
        
        return mapping
    }
    
}

