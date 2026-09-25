//
//  V1MigrationPlan.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

enum V1MigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [
        V1Schema.self
    ]
    
    static let stages: [MigrationStage] = []
}
