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
        switch storeService.loadingState {
        case .loading, .v2Migrating:
            ContainerLoadingView()
            
        case .containerFailure:
            ContainerFailureView()
            
        case .v1Ready(let container, let event):
            V1ContainerView(event: event)
                .modelContainer(container)
            
        case .v2Ready(let container):
            V2ContainerView(needsRepairs: false)
                .modelContainer(container)
            
        case .v2NeedsRepair(let container):
            V2ContainerView(needsRepairs: true)
                .modelContainer(container)
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreService(inMemoryOnly: true))
}
