//
//  Constants.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Foundation

enum Constants {
    enum Settings {
        static let schemaHeader = "SCHEMA"
        static let sampleDataHeader = "SAMPLE DATA"
        static let upgradeHeader = "UPGRADE"

        static func version(_ number: Int) -> String {
            "Version \(number)"
        }

        static let seedingSucceeded = "Seeding complete."
        static let seedingFailed = "Seeding failed. Please try again."

        static let healthy = "Healthy"
        static let migrationFailed = "Migration Failed"

        static let healthyFooter =
            "Migrating is permanent. Any changes that should persist into V2 should be made before migrating."
        static let failedFooter =
            "V2 Migration failed to load container. Please try migrating again."

        static let migrateToV2 = "Migrate to V2"
        static let retryV2Migration = "Retry V2 Migration"
        static let migrateHealthySymbol = "arrow.right.circle.fill"
        static let migrateFailedSymbol = "arrow.counterclockwise.circle.fill"

        static let contactsSeeded = "Contacts seeded"
        static let seedContacts = "Seed Contacts"
        static let seedFooter = "Load a demo contact list into this V1 store."

        static let migrateHealthyDescription =
            "Moves your contacts into the V2 schema. This can’t be undone from Settings."
        static let migrateFailedDescription =
            "Opens V2 again after a failed container load."
        static let migratingDescription = "Migrating to Version 2…"
    }
}
