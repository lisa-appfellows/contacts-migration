//
//  ContactEditorComponents.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-24.
//

import SwiftUI

extension View {
    func editorViewStyle(
        navTitle: String,
        didSave: @escaping () -> Void,
        didDismiss: @escaping () -> Void
    ) -> some View {
        modifier(EditorViewStyleModifier(
            navTitle: navTitle,
            didSave: didSave,
            didDismiss: didDismiss
        ))
    }
}

struct EditorViewStyleModifier: ViewModifier {
    let navTitle: String
    let didSave: () -> Void
    let didDismiss: () -> Void

    func body(content: Content) -> some View {
        content
            .environment(\.editMode, .constant(.active))
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditorDismissToolbarButton(didDismiss: didDismiss)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditorSaveToolbarButton(didSave: didSave)
                }
            }
    }
}

struct EditorSaveToolbarButton: View {
    let didSave: () -> Void

    var body: some View {
        Button(action: didSave) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white, .blue)
        }
    }
}

struct EditorDismissToolbarButton: View {
    let didDismiss: () -> Void

    var body: some View {
        Button(action: didDismiss) {
            Image(systemName: "xmark.circle")
        }
    }
}

struct EditorProfileIconRow: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .frame(width: 120, height: 120)
                .background(
                    Circle().fill(.blue.gradient)
                )
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}

struct EditorNameRow: View {
    @Binding var firstName: String
    @Binding var lastName: String
    @Binding var company: String

    var body: some View {
        Section {
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            TextField("Company", text: $company)
        }
    }
}


struct EditorMetadataSection<Content: View, Item: Hashable>: View {
    @Binding var items: [Item]
    let itemLimit: Int?
    let newItem: () -> Item
    let title: String
    @ViewBuilder let content: (Binding<Item>) -> Content

    private var canAdd: Bool {
        guard let itemLimit else { return true }
        return items.count < itemLimit
    }

    var body: some View {
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

struct EditorNotesSection: View {
    @Binding var notes: String

    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Notes")
                TextEditor(text: $notes)
            }
            .frame(height: 180)
        }
    }
}

struct EditorDeleteContactRow: View {
    let didDelete: () -> Void

    var body: some View {
        Button(role: .destructive, action: didDelete) {
            Text("Delete Contact")
        }
    }
}
