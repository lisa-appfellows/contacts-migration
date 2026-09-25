//
//  ContactUnavailableView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

struct ContactUnavailableView: View {
    let reloadAction: () -> Void

    var body: some View {
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
