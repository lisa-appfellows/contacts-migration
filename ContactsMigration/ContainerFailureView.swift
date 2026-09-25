//
//  ContainerFailureView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import SwiftUI

struct ContainerFailureView: View {
    @Environment(StoreService.self) private var storeService

    var body: some View {
        ContentUnavailableView {
            Label("Unable to Load Contacts", systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text("Something went wrong while opening your contacts. Tap Reload to try again.")
        } actions: {
            Button(action: reload) {
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
    ContainerFailureView()
        .environment(StoreService())
}
