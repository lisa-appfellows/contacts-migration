//
//  V1ContainerView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import SwiftData
import SwiftUI

struct V1ContainerView: View {
    @Environment(StoreService.self) private var storeService
    let event: StoreEvent

    @Query private var contacts: [V1Contact] = []
    @State private var router = V1Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            ContactListView(model: .init(contacts: contacts)) {
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

    private func saveContact(_ vm: V1ContactVM) {
        
    }

    private func migrateTapped() {
        storeService.migrateToV2()
    }
}

#Preview {
    NavigationStack {
        V1ContainerView(event: .v2ContainerFailed)
            .environment(StoreService(inMemoryOnly: true))
            .environment(V1Router())
    }
}
