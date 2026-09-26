//
//  ContactUnavailableView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct ContactUnavailableView: View {
    private let reloadAction: () -> Void

    public init(reloadAction: @escaping () -> Void) {
        self.reloadAction = reloadAction
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Contact", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text("Something went wrong while opening your contact. Tap Reload to try again.")
        } actions: {
            Button(action: reloadAction) {
                Text("Reload")
                    .font(.system(.title3, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical)
                    .background(Capsule())
            }
        }
    }
}

#Preview {
    ContactUnavailableView {

    }
}
