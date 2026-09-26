//
//  EditorMetadataSection.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorMetadataSection<Content: View, Item: Hashable>: View {
    @Binding private var items: [Item]
    private let itemLimit: Int?
    private let newItem: () -> Item
    private let title: String
    @ViewBuilder private let content: (Binding<Item>) -> Content

    public init(
        items: Binding<[Item]>,
        itemLimit: Int?,
        newItem: @escaping () -> Item,
        title: String, @ViewBuilder content: @escaping (Binding<Item>) -> Content) {
        _items = items
        self.itemLimit = itemLimit
        self.newItem = newItem
        self.title = title
        self.content = content
    }

    private var canAdd: Bool {
        guard let itemLimit else { return true }
        return items.count < itemLimit
    }

    public var body: some View {
        Section {
            ForEach($items, id: \.self) { $item in
                content($item)
            }
            .onDelete { indexSet in
                items.remove(atOffsets: indexSet)
            }
            
            Button {
                withAnimation {
                    items.append(newItem())
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.white, .green)
                        .font(.title3)
                    Text(title)
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            .disabled(!canAdd)
            .opacity(canAdd ? 1 : 0.3)
        }
    }
}
