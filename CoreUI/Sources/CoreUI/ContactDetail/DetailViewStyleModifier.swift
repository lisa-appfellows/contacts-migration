//
//  DetailViewStyleModifier.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

extension View {
    /// Shared detail chrome. Pass `nil` `editAction` to omit the Edit toolbar button
    /// (e.g. V2 contact still behind on repair).
    public func detailViewStyle(editAction: (() -> Void)? = nil) -> some View {
        modifier(DetailViewStyleModifier(editAction: editAction))
    }
}

struct DetailViewStyleModifier: ViewModifier {
    let editAction: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Material.ultraThin, for: .navigationBar)
            .toolbar {
                if let editAction {
                    ToolbarItem(placement: .topBarTrailing) {
                        DetailEditToolbarButton(action: editAction)
                    }
                }
            }
    }
}
