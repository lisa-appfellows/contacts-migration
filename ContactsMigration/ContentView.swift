//
//  ContentView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import SwiftUI

struct ContentView: View {
    @Environment(StoreService.self) private var storeService

    var body: some View {
        NavigationStack {
            if storeService.isLoading {
                ProgressView()
            } else {
                Text("Hello")
            }
        }
        .modelContainer(storeService.modelContainer)
    }
}

#Preview {
    ContentView()
        .environment(StoreService(inMemoryOnly: true))
}
