//
//  AppLogger.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation
import OSLog

public enum AppLogger {
    static let subsystem = "dev.appfellows.ContactsMigration"
    public static let postMigration = Logger(subsystem: subsystem, category: "PostMigration")
    public static let storeRepository = Logger(subsystem: subsystem, category: "StoreRepository")
    public static let storeService = Logger(subsystem: subsystem, category: "StoreService")
}
