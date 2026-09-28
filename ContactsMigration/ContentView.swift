//
//  ContentView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Core
import CoreUI
import SwiftData
import SwiftUI
import Version1
import Version2

struct ContentView: View {
    @Environment(StoreService.self) private var storeService
    
    var body: some View {
        switch storeService.loadingState {
        case .loading:
            ContainerLoadingView()
            
        case .containerFailure:
            ContainerFailureView {
                storeService.reloadContainer()
            }
            
        case .v1Ready(let container):
            Version1.containerView {
                storeService.migrateToV2()
            }
            .modelContainer(container)
            
        case .v2Ready(let container):
            Version2.containerView()
                .modelContainer(container)
        }
    }
}

#Preview {
    ContentView()
        .environment(StoreService(inMemoryOnly: true))
}
