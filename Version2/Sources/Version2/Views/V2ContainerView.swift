//
//  V2ContainerView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftData
import SwiftUI

struct V2ContainerView: View {
    let needsRepairs: Bool
    let refreshRepairsTapped: () -> Void

    @Query private var contacts: [V2Contact] = []
    @State private var router = V2Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            ContactListView(
                model: .init(version: 2, contacts: contacts),
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
        // TODO: Version Tapped()
    }

    private func saveContact(_ vm: V2ContactVM) {
        // TODO: Save Contact
    }

    private func refreshRepairs() {
        // TODO: Refresh Repairs
    }
}

#Preview {
    NavigationStack {
        V2ContainerView(needsRepairs: true) {
            
        }
        .environment(V2Router())
    }
}

