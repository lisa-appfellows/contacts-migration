//
//  V2ContainerView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import SwiftData
import SwiftUI

struct V2ContainerView: View {
    @Environment(StoreService.self) private var storeService
    let needsRepairs: Bool

    @Query private var contacts: [V2Contact] = []
    @State private var router = V2Router()

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

    private func saveContact(_ vm: V2ContactVM) {
            
    }

    private func refreshRepairs() {
        
    }
}

#Preview {
    NavigationStack {
        V2ContainerView(needsRepairs: true)
            .environment(StoreService(inMemoryOnly: true))
            .environment(V2Router())
    }
}
