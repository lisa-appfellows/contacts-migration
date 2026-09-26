//
//  EditorViewStyleModifier.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

extension View {
    public func editorViewStyle(
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
