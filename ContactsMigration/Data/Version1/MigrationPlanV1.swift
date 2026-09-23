//
//  MigrationPlanV1.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

enum MigrationPlanV1: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [
        SchemaV1.self
    ]
    
    static let stages: [MigrationStage] = []
}
