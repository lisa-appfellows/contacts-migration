//
//  ContentView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(StoreService.self) private var storeService

    var body: some View {
        NavigationStack {
            switch storeService.loadingState {
            case .loading, .v2Migrating:
                ProgressView()
            case .containerFailure:
                Text("Store unavailable")
            case .v1Ready(let container, _):
                Text("Hello")
                    .modelContainer(container)
            case .v2Ready(let container), .v2NeedsRepair(let container):
                Text("Hello")
                    .modelContainer(container)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreService(inMemoryOnly: true))
}
