//
//  DetailViewStyleModifier.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

extension View {
    public func detailViewStyle(editAction: @escaping () -> Void) -> some View {
        modifier(DetailViewStyleModifier(editAction: editAction))
    }
}

struct DetailViewStyleModifier: ViewModifier {
    let editAction: () -> Void

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(LinearGradient.blueWash)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DetailEditToolbarButton(action: editAction)
                }
            }
    }
}
