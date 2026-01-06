import Foundation
import UIKit
import Combine
import Spine
import SpineCppLite


/// 编辑器 UI 状态，对应 Android 的 EditorUiState
struct EditorUiState {
    var isLoading: Bool = false
    var isError: Bool = false
    var editor: Editor? = nil
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
    @Published var avatar = Avatar()
    @Published var canUndo = false
    @Published var canRedo = false
    @Published var showPalette = false
    @Published var exportUiState = ExportUiState()
    
    private var isInitialized = false
    let thumbnailSize = CGSize(width: 200, height: 200)

    var editor: Editor? {
        editorUiState.editor
    }
    
    private var history: [Avatar] = []
    private var historyIndex: Int = -1
    private let maxHistorySize = 50
    
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
        editor?.skeletonDrawable.dispose()
//        customSkin?.dispose()
    }
    
    /// 加载编辑器，对应 Android 的 loadEditor
    func loadEditor() {
        editorUiState = EditorUiState(isLoading: true, isError: false)
        
        Task {
            do {
                let editor = try await loadEditorAsync()
                await MainActor.run {
                    editorUiState = EditorUiState(
                        isLoading: false,
                        isError: false,
                        editor: editor
                    )
                    
                    // 如果有初始 Avatar，设置它
                    if var initAvatar = editor.template.initAvatar {
                        initAvatar.tonings = [:]
                        setupInitAvatar(initAvatar)
                    }
                }
            } catch {
                print("❌ [SpineEditorViewModel] 加载编辑器失败: \(error)")
                await MainActor.run {
                    editorUiState = EditorUiState(isLoading: false, isError: true)
                }
            }
        }
    }
    
    /// 异步加载编辑器
    @MainActor
    private func loadEditorAsync() async throws -> Editor {
        return try await Task.detached(priority: .high) {
            // 加载 Template
            let template = try self.getTemplate(templateId: self.templateId)
            
            // 加载 SkeletonDrawable
            let drawable = try await self.getSkeletonDrawable(templateId: self.templateId)
            
            // 获取皮肤缩略图
            let skeletonSkins = try await SpineUtils.getSkeletonSkins(drawable: drawable)
            
            // 获取 SKU Slots 映射
            let skeletonSlots = SpineUtils.getSkeletonSlots(drawable: drawable, template: template)
            
            // 排序 selections
            let sortedSelections = template.selections.sorted { $0.playIndex < $1.playIndex }
            let sortedTemplate = Template(
                selections: sortedSelections,
                tonings: template.tonings,
                animations: template.animations,
                requireCategories: template.requireCategories,
                initAvatar: template.initAvatar
            )
            
            return Editor(
                template: sortedTemplate,
                skeletonDrawable: drawable,
                skeletonSkins: skeletonSkins,
                skuSlots: skeletonSlots
            )
        }.value
    }
    
    /// 获取 Template，对应 Android 的 getTemplate
    private func getTemplate(templateId: String) throws -> Template {
        guard let bundle = Bundle.main.path(forResource: "\(templateId)", ofType: "json") else {
            throw NSError(domain: "SpineEditorViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "找不到模板文件"])
        }
        
        let data = try Data(contentsOf: URL(fileURLWithPath: bundle))
        return try JSONDecoder().decode(Template.self, from: data)
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
    private func setupInitAvatar(_ initAvatar: Avatar) {
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
        
        let newAvatar = Avatar(
            version: avatar.version,
            skus: currentSkus,
            tonings: avatar.tonings,
            animation: avatar.animation
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
        
        let newAvatar = Avatar(
            version: avatar.version,
            skus: selectedSkus,
            tonings: avatar.tonings,
            animation: avatar.animation
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
        if selectedTonings?[toningId] == colorId {
            selectedTonings?.removeValue(forKey: toningId)
        } else {
            selectedTonings?[toningId] = colorId
        }
        
        let newAvatar = Avatar(
            version: avatar.version,
            skus: avatar.skus,
            tonings: selectedTonings,
            animation: avatar.animation
        )
        updateAvatar(newAvatar)
    }
    
    /// 检查颜色是否已选中，对应 Android 的 isColorSelected
    func isColorSelected(toningId: String, colorId: String) -> Bool {
        return avatar.tonings?[toningId] == colorId
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
        
        // 阶段2：处理可选 Categories（40%概率）
        let allCategories = Set(categoryToSkus.keys)
        let optionalCategories = allCategories.subtracting(Set(requireCategories))
        
        for optionalCategory in optionalCategories {
            if Double.random(in: 0..<1) < 0.4 {
                if let candidates = categoryToSkus[optionalCategory], !candidates.isEmpty {
                    if let selectedSku = candidates.randomElement() {
                        selectedSkus.insert(selectedSku.id)
                    }
                }
            }
        }
        
        // 生成新 Avatar（清空染色）
        let newAvatar = Avatar(
            version: avatar.version,
            skus: Array(selectedSkus),
            tonings: [:],
            animation: avatar.animation
        )
        updateAvatar(newAvatar)
    }
    
    /// 构建 Category -> SKUs 的索引映射，对应 Android 的 buildCategoryToSkusMap
    private func buildCategoryToSkusMap(template: Template) -> [String: [Sku]] {
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
    private func updateAvatar(_ newAvatar: Avatar) {
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
    
    /// 导出，对应 Android 的 export
    func export() {
        guard let editor = editor else { return }
        
        exportUiState = ExportUiState(isLoading: true, export: nil)
        
        Task {
            do {
                let export = try await exportAsync(editor: editor)
                await MainActor.run {
                    exportUiState = ExportUiState(isLoading: false, export: export)
                }
            } catch {
                print("❌ [SpineEditorViewModel] 导出失败: \(error)")
                await MainActor.run {
                    exportUiState = ExportUiState(isLoading: false, export: nil)
                }
            }
        }
    }
    
    /// 异步导出
    private func exportAsync(editor: Editor) async throws -> Export {
        let recorder = SpineRecorder(drawable: editor.skeletonDrawable)
        let fileName = "\(Int64(Date().timeIntervalSince1970 * 1000)).gif"
        
        // 创建临时文件
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        // 录制 GIF（内部会确保在主线程执行渲染）
        try await recorder.recordGif(animationName: "idle_default", output: fileURL)
        
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
}

