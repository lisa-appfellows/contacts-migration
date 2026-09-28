//
//  Constants.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Foundation

enum Constants {
    enum PostMigration {
        static let fetchModelFailure = "Failed to fetch models, aborting post-migration."
    }

    enum Store {
        static func repairStateBehind(version: Int, currentVersion: Int) -> String {
            "Cannot update, repairVersion \(version) is behind \(currentVersion)"
        }
    }

    enum Repair {
        static let containerFailureMessage =
            "Post-migration could not finish after multiple attempts."
        static let contactFailureMessage =
            "This contact still needs repair. Try again to finish updating it."
        static let editBlockedMessage =
            "This contact needs repair before it can be edited."
        static let repairing = "Repairing contacts…"
        static let tryAgain = "Try Again"
    }

    enum Settings {
        static let schemaHeader = "SCHEMA"
        static let postMigrationHeader = "POST-MIGRATION"
        static let actionsHeader = "ACTIONS"

        static func version(_ number: Int) -> String {
            "Version \(number)"
        }

        static let healthy = "Healthy"
        static let repairing = "Repairing"
        static let repairFailed = "Repair Failed"

        static let idleFooter = "Contacts are up to date for Version 2."
        static let runningFooter = "Post-migration is repairing contacts. You can keep browsing."
        static let failedFooter =
            "Post-migration failed after multiple attempts. Use Hard Refresh to try again."

        static let hardRefresh = "Hard Refresh Repairs"
        static let hardRefreshSymbol = "arrow.clockwise.circle.fill"
        static let repairingInProgress = "Repairing..."
        static let hardRefreshDescription =
            "Re-runs post-migration for any contacts still behind on repair."
    }
}
