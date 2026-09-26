//
//  EditorToolbarButtons.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorSaveToolbarButton: View {
    private let didSave: () -> Void

    public init(didSave: @escaping () -> Void) {
        self.didSave = didSave
    }

    public var body: some View {
        Button(action: didSave) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.white, .blue)
        }
    }
}

public struct EditorDismissToolbarButton: View {
    private let didDismiss: () -> Void

    public init(didDismiss: @escaping () -> Void) {
        self.didDismiss = didDismiss
    }

    public var body: some View {
        Button(action: didDismiss) {
            Image(systemName: "xmark.circle")
        }
    }
}
