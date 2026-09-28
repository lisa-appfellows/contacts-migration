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

    @State private var coordinator = Coordinator()
    /// Keep `@Query` off until the first post-migration pass finishes.
    @State private var hasFinishedInitialRepair = false

    var body: some View {
        Group {
            if hasFinishedInitialRepair {
                ContactsRootView(coordinator: coordinator)
            } else {
                ContainerLoadingView()
            }
        }
        .environment(coordinator)
        .onAppear {
            // Only auto-start the first pass. Later appears (foreground, etc.)
            // must not re-trigger store-wide repair and flash list chrome.
            guard !hasFinishedInitialRepair else { return }
            coordinator.refreshRepairs(context: context)
        }
        .onChange(of: coordinator.repairState) { _, state in
            guard !hasFinishedInitialRepair else { return }
            if state == .idle || state == .failed {
                hasFinishedInitialRepair = true
            }
        }
    }
}

/// Mounted only after the first Coordinator repair pass.
@MainActor
private struct ContactsRootView: View {
    @Environment(\.modelContext) private var context
    @Bindable var coordinator: Coordinator

    @Query private var contacts: [Contact]
    @State private var router = Router()

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            ContactListView(
                model: .init(version: 2, contacts: contacts),
                versionTapped: { router.presentVersionSettings() },
                newContactTapped: { router.presentEditor() }
            )
            .safeAreaInset(edge: .top, spacing: 0) {
                repairChrome
            }
            .navigationDestination(for: String.self) { stableId in
                if let dto = dto(for: stableId) {
                    ContactDetailView(dto: dto) {
                        router.presentEditor(stableId: stableId)
                    }
                    .id("\(dto.stableId)-\(dto.repairVersion)")
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
                    VersionSettings(coordinator: coordinator)
                }
            }
        }
        .environment(router)
    }

    @ViewBuilder
    private var repairChrome: some View {
        switch coordinator.repairState {
        case .failed:
            RepairFailureBanner(message: Constants.Repair.containerFailureMessage) {
                coordinator.refreshRepairs(context: context)
            }

        case .running:
            HStack(spacing: 10) {
                ProgressView()
                    .controlSize(.small)
                Text(Constants.Repair.repairing)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.bar)

        case .idle:
            EmptyView()
        }
    }

    private func dto(for stableId: String) -> ContactDTO? {
        contacts.first(where: { $0.stableId == stableId })?.asDTO
    }
}

#Preview {
    ContainerView()
        .modelContainer(PreviewSupport.container)
}
