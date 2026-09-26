//
//  ContentView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import CoreUI
import SwiftData
import SwiftUI
import Version1
import Version2

struct ContentView: View {
    @Environment(StoreService.self) private var storeService
    
    var body: some View {
        switch storeService.loadingState {
        case .loading, .v2Migrating:
            ContainerLoadingView()
            
        case .containerFailure:
            ContainerFailureView {
                // TODO: Reload Action
            }
            
        case .v1Ready(let container, let event):
            Version1.containerView(event: event) {
                // TODO: Migrate Tapped
            }
            .modelContainer(container)
            
        case .v2Ready(let container):
            Version2.containerView(needsRepairs: false) {
                // TODO: Refresh Repairs Tapped
            }
            .modelContainer(container)
            
        case .v2NeedsRepair(let container):
            Version2.containerView(needsRepairs: true) {
                // TODO: Refresh Repairs Tapped
            }
            .modelContainer(container)
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreService(inMemoryOnly: true))
}
