//
//  AppLogger.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import OSLog

enum AppLogger {
    static let subsystem = "dev.appfellows.ContactsMigration"
    static let postMigration = Logger(subsystem: subsystem, category: "PostMigration")
    static let storeRepository = Logger(subsystem: subsystem, category: "StoreRepository")
    static let storeService = Logger(subsystem: subsystem, category: "StoreService")
}
