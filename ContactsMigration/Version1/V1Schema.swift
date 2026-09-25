//
//  V1Schema.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

enum V1Schema: VersionedSchema {
    static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    static let models: [any PersistentModel.Type] = [Contact.self]
}
