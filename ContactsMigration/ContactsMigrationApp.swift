//
//  ContactsMigrationApp.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import SwiftData
import SwiftUI

@main
struct ContactsMigrationApp: App {
    @State private var storeService = StoreService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(storeService.isVersion1)
                .environment(storeService)
        }
    }
}
