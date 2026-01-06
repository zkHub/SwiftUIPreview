import Foundation
import SwiftUI
import Combine

// 编辑器UI状态
enum EditorUiState {
    case loading
    case error
    case loaded(Editor)
    
    // 是否正在加载
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    // 是否出错
    var isError: Bool {
        if case .error = self { return true }
        return false
    }
    
    // 获取编辑器实例
    var editor: Editor? {
        if case .loaded(let editor) = self { return editor }
        return nil
    }
}

// 导出UI状态
enum ExportUiState {
    case idle
    case loading
    case exported(Export)
    
    // 是否正在加载
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    // 获取导出结果
    var export: Export? {
        if case .exported(let export) = self { return export }
        return nil
    }
}

// Editor 模型，对应Android的Editor.kt
struct Editor {
    let template: Template
    let skeletonDrawable: SkeletonDrawable
    let skeletonSkins: [String: UIImage] // skinName: image
    let skuSlots: [String: Set<String>] // skuId: slotNames
}

// Export 模型，对应Android的Export.kt
struct Export {
    let avatar: Avatar
    let imageFile: URL
}

// SpineEditorViewModel 视图模型，对应Android的SpineEditorViewModel.kt
class SpineEditorViewModel: ObservableObject {
    private var isInitialized = false
    private var templateId: String = ""
    
    // 编辑器UI状态
    @Published private(set) var editorUiState: EditorUiState = .loading
    
    // Avatar状态
    @Published private(set) var avatar: Avatar = Avatar()
    
    // 历史记录管理
    private var history: [Avatar] = []
    private var historyIndex: Int = -1
    private let maxHistorySize: Int = 50
    
    // 撤销/重做状态
    @Published private(set) var canUndo: Bool = false
    @Published private(set) var canRedo: Bool = false
    
    // 调色板显示状态
    @Published private(set) var showPalette: Bool = false
    
    // 导出UI状态
    @Published private(set) var exportUiState: ExportUiState = .idle
    
    // 获取当前编辑器实例
    var editor: Editor? {
        return editorUiState.editor
    }
    
    // 初始化方法
    func initialize(templateId: String) {
        if isInitialized {
            return
        }
        isInitialized = true
        self.templateId = templateId
        loadEditor()
    }
    
    // 加载编辑器
    private func loadEditor() {
        // 模拟异步加载
        DispatchQueue.main.async {
            self.editorUiState = .loading
        }
        
        DispatchQueue.global(qos: .background).async {
            do {
                // 加载模板
                let template = try self.getTemplate(templateId: self.templateId)
                
                // 加载骨骼资源
                let skeletonDrawable = try self.getSkeletonDrawable(templateId: self.templateId)
                
                // 获取骨骼皮肤
                let skeletonSkins = SpineUtils.shared.getSkeletonSkins(drawable: skeletonDrawable)
                
                // 获取SKU插槽映射
                let skeletonSlots = SpineUtils.shared.getSkeletonSlots(drawable: skeletonDrawable, template: template)
                
                // 创建编辑器实例
                let editor = Editor(
                    template: template.copy(selections: template.selections.sorted { $0.playIndex < $1.playIndex }),
                    skeletonDrawable: skeletonDrawable,
                    skeletonSkins: skeletonSkins,
                    skuSlots: skeletonSlots
                )
                
                // 更新UI状态
                DispatchQueue.main.async {
                    self.editorUiState = .loaded(editor)
                    
                    // 设置初始Avatar
                    if let initAvatar = editor.template.initAvatar {
                        self.setupInitAvatar(initAvatar)
                    }
                }
            } catch {
                print("Failed to load editor: \(error)")
                DispatchQueue.main.async {
                    self.editorUiState = .error
                }
            }
        }
    }
    
    // 设置初始Avatar
    private func setupInitAvatar(_ initAvatar: Avatar) {
        self.avatar = initAvatar
        history.removeAll()
        history.append(initAvatar.copy())
        historyIndex = 0
        updateUndoRedoState()
    }
    
    // 获取骨骼Drawable
    private func getSkeletonDrawable(templateId: String) throws -> SkeletonDrawable {
        // 简化实现，实际应从资源加载atlas和json文件
        // 这里返回一个空的SkeletonDrawable作为示例
        let atlas = try Atlas(name: "spine/spine-\(templateId)")
        let skeletonData = try SkeletonData(atlas: atlas, name: "spine/spine-\(templateId)")
        return SkeletonDrawable(skeletonData)
    }
    
    // 获取模板
    private func getTemplate(templateId: String) throws -> Template {
        // 简化实现，实际应从JSON文件加载
        // 这里返回一个空模板作为示例
        return Template()
    }
    
    // 选择SKU
    func selectSku(_ sku: Sku) {
        guard let editor = editor else { return }
        var currentSkus = avatar.skus
        
        // 构建skuId -> Sku的映射
        let allSkusMap = editor.template.selections
            .flatMap { $0.skus }
            .reduce(into: [String: Sku]()) { $0[$1.id] = $1 }
        
        // 找到当前已选中的同category的SKU
        let existingSkuId = currentSkus.first { skuId in
            guard let existingSku = allSkusMap[skuId] else { return false }
            return existingSku.category == sku.category
        }
        
        if let existingSkuId = existingSkuId, existingSkuId != sku.id {
            // 替换同category的SKU
            if let index = currentSkus.firstIndex(of: existingSkuId) {
                currentSkus[index] = sku.id
            }
        } else if existingSkuId == nil {
            // 添加新SKU
            currentSkus.append(sku.id)
        }
        // 如果existingSkuId == sku.id，说明已经选中，不做操作
        
        let newAvatar = avatar.copy(skus: currentSkus)
        updateAvatar(newAvatar)
    }
    
    // 取消选择SKU
    func unselectSku(_ sku: Sku) {
        guard let editor = editor else { return }
        
        // 检查是否是必选category
        let requireCategories = editor.template.requireCategories ?? []
        if requireCategories.contains(sku.category) {
            // 必选category不能取消选择
            return
        }
        
        var selectedSkus = avatar.skus
        selectedSkus.removeAll { $0 == sku.id }
        let newAvatar = avatar.copy(skus: selectedSkus)
        updateAvatar(newAvatar)
    }
    
    // 检查SKU是否被选中
    func isSkuSelected(_ skuId: String) -> Bool {
        return avatar.skus.contains(skuId)
    }
    
    // 切换SKU选择状态
    func toggleSelectSku(_ sku: Sku) {
        if isSkuSelected(sku.id) {
            unselectSku(sku)
        } else {
            selectSku(sku)
        }
    }
    
    // 选择颜色
    func selectColor(toningId: String, colorId: String) {
        var selectedTonings = avatar.tonings
        
        if selectedTonings[toningId] == colorId {
            // 如果已经选中该颜色，取消选择
            selectedTonings.removeValue(forKey: toningId)
        } else {
            // 否则选择该颜色
            selectedTonings[toningId] = colorId
        }
        
        let newAvatar = avatar.copy(tonings: selectedTonings)
        updateAvatar(newAvatar)
    }
    
    // 检查颜色是否被选中
    func isColorSelected(toningId: String, colorId: String) -> Bool {
        return avatar.tonings[toningId] == colorId
    }
    
    // 获取皮肤图片
    func getSkinBitmap(skinName: String) -> UIImage? {
        return editor?.skeletonSkins[skinName]
    }
    
    // 重置Avatar
    func resetAvatar() {
        guard let initAvatar = editor?.template.initAvatar, initAvatar != avatar else {
            return
        }
        updateAvatar(initAvatar)
    }
    
    // 随机生成Avatar
    func randomAvatar() {
        guard let editor = editor else { return }
        let template = editor.template
        
        // 步骤1：构建Category -> SKUs的索引
        let categoryToSkus = buildCategoryToSkusMap(template)
        
        // 步骤2：选择SKU
        var selectedSkus = Set<String>()
        
        // 阶段1：处理必选Categories（100%概率）
        let requireCategories = template.requireCategories ?? []
        for requiredCategory in requireCategories {
            guard let candidates = categoryToSkus[requiredCategory], !candidates.isEmpty else {
                continue
            }
            let selectedSku = candidates.randomElement()!
            selectedSkus.insert(selectedSku.id)
        }
        
        // 阶段2：处理可选Categories（40%概率）
        let allCategories = categoryToSkus.keys
        let optionalCategories = allCategories.subtracting(Set(requireCategories))
        
        for optionalCategory in optionalCategories {
            // 40%概率选择
            if Double.random(in: 0..<1) < 0.4 {
                guard let candidates = categoryToSkus[optionalCategory], !candidates.isEmpty else {
                    continue
                }
                let selectedSku = candidates.randomElement()!
                selectedSkus.insert(selectedSku.id)
            }
        }
        
        // 步骤3：生成新Avatar（清空染色）
        let newAvatar = avatar.copy(
            skus: Array(selectedSkus),
            tonings: [:]
        )
        updateAvatar(newAvatar)
    }
    
    // 构建Category -> SKUs的映射
    private func buildCategoryToSkusMap(_ template: Template) -> [String: [Sku]] {
        var categoryToSkus: [String: [Sku]] = [:]
        
        for selection in template.selections {
            for sku in selection.skus {
                var skus = categoryToSkus[sku.category] ?? []
                skus.append(sku)
                categoryToSkus[sku.category] = skus
            }
        }
        
        return categoryToSkus
    }
    
    // 撤销操作
    func undo() {
        if !canUndo { return }
        
        historyIndex -= 1
        if historyIndex >= 0 {
            avatar = history[historyIndex].copy()
            updateUndoRedoState()
        }
    }
    
    // 重做操作
    func redo() {
        if !canRedo { return }
        
        historyIndex += 1
        if historyIndex < history.count {
            avatar = history[historyIndex].copy()
            updateUndoRedoState()
        }
    }
    
    // 更新撤销/重做状态
    private func updateUndoRedoState() {
        canUndo = historyIndex > 0
        canRedo = historyIndex < history.count - 1
    }
    
    // 更新Avatar并添加到历史记录
    private func updateAvatar(_ newAvatar: Avatar) {
        // 移除当前索引之后的历史记录
        if historyIndex < history.count - 1 {
            history.removeSubrange(historyIndex + 1..<history.count)
        }
        
        // 添加新记录
        history.append(newAvatar.copy())
        
        // 限制历史记录大小
        if history.count > maxHistorySize {
            history.removeFirst()
        } else {
            historyIndex += 1
        }
        
        // 更新当前Avatar
        avatar = newAvatar
        
        // 更新撤销/重做状态
        updateUndoRedoState()
    }
    
    // 导出Avatar
    func export() {
        guard let editor = editor else { return }
        
        exportUiState = .loading
        
        DispatchQueue.global(qos: .background).async {
            do {
                // 创建导出目录
                let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let fileName = "\(Date().timeIntervalSince1970).gif"
                let fileUrl = documentsDirectory.appendingPathComponent(fileName)
                
                // 录制GIF
                let recorder = SpineRecorder(editor.skeletonDrawable)
                try recorder.recordGif(animationName: "idle_default", output: fileUrl)
                
                // 创建导出结果
                let export = Export(avatar: self.avatar, imageFile: fileUrl)
                
                // 更新UI状态
                DispatchQueue.main.async {
                    self.exportUiState = .exported(export)
                }
            } catch {
                print("Failed to export: \(error)")
                DispatchQueue.main.async {
                    self.exportUiState = .idle
                }
            }
        }
    }
    
    // 更新调色板可见性
    func updatePaletteVisibility(selectionIndex: Int) {
        guard let editor = editor else { return }
        let selections = editor.template.selections
        if selectionIndex < 0 || selectionIndex >= selections.count { return }
        
        let currentSelection = selections[selectionIndex]
        let selectedSkus = avatar.skus
        
        // 检查当前选择的SKU是否支持调色
        let isSupport = currentSelection.skus
            .filter { selectedSkus.contains($0.id) }
            .contains { !$0.toningIds.isNullOrEmpty() }
        
        showPalette = isSupport
    }
    
    // 获取ToningSets
    func getToningSets(selectionIndex: Int) -> [ToningSet] {
        guard let editor = editor else { return [] }
        let selections = editor.template.selections
        if selectionIndex < 0 || selectionIndex >= selections.count { return [] }
        
        let currentSelection = selections[selectionIndex]
        let selectedSkus = avatar.skus
        let allTonings = editor.template.tonings ?? []
        
        return currentSelection.skus
            .filter { sku in
                selectedSkus.contains(sku.id) && !sku.toningIds.isNullOrEmpty()
            }
            .compactMap { sku in
                // 找到该SKU关联的所有Toning
                let tonings = sku.toningIds?.compactMap { toningId in
                    allTonings.first { $0.id == toningId }
                } ?? []
                
                return tonings.isEmpty ? nil : ToningSet(sku: sku, tonings: tonings)
            }
    }
}

// 扩展Avatar，添加copy方法
extension Avatar {
    func copy(version: Int64? = nil, skus: [String]? = nil, tonings: [String: String]? = nil, animation: String? = nil) -> Avatar {
        return Avatar(
            version: version ?? self.version,
            skus: skus ?? self.skus,
            tonings: tonings ?? self.tonings,
            animation: animation ?? self.animation
        )
    }
}

// 扩展Template，添加copy方法
extension Template {
    func copy(selections: [Selection]? = nil, tonings: [Toning]? = nil, animations: [Animation]? = nil, requireCategories: [String]? = nil, initAvatar: Avatar? = nil) -> Template {
        return Template(
            selections: selections ?? self.selections,
            tonings: tonings ?? self.tonings,
            animations: animations ?? self.animations,
            requireCategories: requireCategories ?? self.requireCategories,
            initAvatar: initAvatar ?? self.initAvatar
        )
    }
}

// 扩展Collection，添加判断是否为空的便捷方法
extension Collection {
    var isNullOrEmpty: Bool {
        return self.isEmpty
    }
}