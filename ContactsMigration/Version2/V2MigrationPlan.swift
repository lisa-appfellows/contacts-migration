//
//  V2MigrationPlan.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import SwiftData

enum V2MigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [
        V1Schema.self, V2Schema.self
    ]

    static let stages: [MigrationStage] = [
        .lightweight(fromVersion: V1Schema.self, toVersion: V2Schema.self)
    ]
}
