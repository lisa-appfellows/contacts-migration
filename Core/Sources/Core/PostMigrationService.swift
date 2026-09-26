//
//  PostMigrationService.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftData
import SwiftUI

public protocol PostMigrationService: ModelActor {
    static var currentVersion: Int { get }
    func runIfNeeded() throws
}
