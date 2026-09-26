//
//  V1ContainerView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftData
import SwiftUI

struct V1ContainerView: View {
    let event: Version1.StoreEvent
    let migrateTapped: () -> Void

    @Query private var contacts: [V1Contact] = []
    @State private var router = V1Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            ContactListView(
                model: .init(version: 1, contacts: contacts),
                versionTapped: versionTapped
            ) {
                router.presentEditor()
            }
            .onAppear {
                router.createDictionary(from: contacts)
            }
            .navigationDestination(for: String.self) { stableId in
                router.detailView(for: stableId)
            }
            .sheet(item: $router.sheet) { sheet in
                sheet.view(didSave: saveContact)
            }
        }
        .environment(router)
    }

    private func versionTapped() {
        // TODO: Version Tapped
    }

    private func saveContact(_ vm: V1ContactVM) {
        // TODO: Save Contact
    }
}

#Preview {
    NavigationStack {
        V1ContainerView(event: .v2ContainerFailed) {
            
        }
        .environment(V1Router())
    }
}
