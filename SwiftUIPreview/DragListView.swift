//
//  DragListView.swift
//  SwiftUIPreview
//
//  Created by zk on 2025/5/20.
//

import SwiftUI

struct DragReorderListView: View {
    @State private var items = ["苹果", "香蕉", "橙子", "葡萄", "梨子"]

    var body: some View {
        NavigationView {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
                .onMove(perform: move)
            }
            .navigationTitle("水果列表")
            .toolbar {
                EditButton()
            }
        }
    }

    private func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}


