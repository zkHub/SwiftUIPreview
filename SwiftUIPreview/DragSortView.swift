//
//  DragSortView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/20.
//

import SwiftUI

struct CustomDragSortView: View {
    @State private var items = ["苹果", "香蕉", "橙子", "葡萄", "梨子"]
    @State private var draggedItem: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .onDrag({
                            self.draggedItem = item
                            return NSItemProvider(object: item as NSString)
                        })
                        .onDrop(of: [.text], delegate: DropViewDelegate(item: item, items: $items, draggedItem: $draggedItem))
                    
                }
            }
            .padding()
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    @Binding var items: [String]
    @Binding var draggedItem: String?

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragged = draggedItem, dragged != item,
              let fromIndex = items.firstIndex(of: dragged),
              let toIndex = items.firstIndex(of: item) else { return }

        withAnimation {
            items.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
