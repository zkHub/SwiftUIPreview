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
            if let drawable = viewModel.drawable {
                SpineView(
                    from: .drawable(drawable),
                    controller: viewModel.controller,
                    boundsProvider: RawBounds(x: -256, y: -512, width: 512, height: 512),
                    backgroundColor: .clear
                )
                .aspectRatio(1.0, contentMode: .fit)
                .onAppear {
                    viewModel.applyAvatar()
                }
                .onChange(of: viewModel.avatar) { _ in
                    viewModel.applyAvatar()
                }

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
