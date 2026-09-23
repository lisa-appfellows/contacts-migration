//
//  MigrationPlanV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import SwiftData

enum MigrationPlanV2: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [
        SchemaV1.self, SchemaV2.self
    ]

    static let stages: [MigrationStage] = [
        .lightweight(fromVersion: SchemaV1.self, toVersion: SchemaV2.self)
    ]
}
