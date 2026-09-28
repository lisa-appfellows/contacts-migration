//
//  ContainerView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftData
import SwiftUI

@MainActor
struct ContainerView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.versionState) private var versionState

    let migrateTapped: () -> Void

    @Query private var contacts: [Contact]
    @State private var router = Router()

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            ContactListView(
                model: .init(version: 1, contacts: contacts),
                versionTapped: { router.presentVersionSettings() },
                newContactTapped: { router.presentEditor() }
            )
            .navigationDestination(for: String.self) { stableId in
                if let dto = dto(for: stableId) {
                    ContactDetailView(dto: dto) {
                        router.presentEditor(stableId: stableId)
                    }
                } else {
                    ContactUnavailableView {
                        router.path.removeLast()
                        router.path.append(stableId)
                    }
                }
            }
            .sheet(item: $router.sheet) { sheet in
                switch sheet {
                case .editor(let stableId):
                    ContactEditor(
                        dto: stableId.flatMap { dto(for: $0) },
                        storeRepo: .init(context: context)
                    )

                case .versionSettings:
                    VersionSettings(
                        storeRepo: .init(context: context),
                        isStoreEmpty: contacts.isEmpty,
                        migrateTapped: migrateTapped
                    )
                }
            }
        }
        .environment(router)
        // Migrate briefly swaps to `.loading`, which tears down this view (and the
        // Settings sheet). On failure we land back on V1 with `.v2ContainerFailed` —
        // reopen Settings so the failed state / Retry CTA is obvious.
        // Also covers cold start after a persisted failed migrate.
        .onAppear {
            if versionState.containerState == .v2ContainerFailed {
                router.presentVersionSettings()
            }
        }
    }

    private func dto(for stableId: String) -> ContactDTO? {
        contacts.first(where: { $0.stableId == stableId })?.asDTO
    }
}

#Preview {
    ContainerView {}
        .modelContainer(PreviewSupport.container)
}
