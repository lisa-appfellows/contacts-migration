//
//  ContainerFailureView.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct ContainerFailureView: View {
    public let reloadAction: () -> Void

    public init(reloadAction: @escaping () -> Void) {
        self.reloadAction = reloadAction
    }

    public var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Contacts", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text("Something went wrong while opening your contacts. Tap Reload to try again.")
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

    private func reload() {
        
    }
}

#Preview {
    ContainerFailureView() {}
}
