//
//  DetailEditToolbarButton.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailEditToolbarButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text("Edit")
                .frame(height: 35)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .background(Color.blue.opacity(0.5))
                .clipShape(Capsule())
        }
    }
}
