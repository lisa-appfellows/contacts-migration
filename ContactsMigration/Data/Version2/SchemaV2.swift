//
//  SchemaV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import SwiftData

enum SchemaV2: VersionedSchema {
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    static let models: [any PersistentModel.Type] = [
        Contact.self, PhoneNumber.self
    ]
}
