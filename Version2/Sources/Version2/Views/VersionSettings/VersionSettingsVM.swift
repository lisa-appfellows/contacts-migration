//
//  VersionSettingsVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class VersionSettingsVM {
    let coordinator: Coordinator

    init(coordinator: Coordinator) {
        self.coordinator = coordinator
    }

    var versionIsHealthy: Bool {
        coordinator.repairState == .idle
    }

    var versionHealth: String {
        switch coordinator.repairState {
        case .idle: return Constants.Settings.healthy
        case .running: return Constants.Settings.repairing
        case .failed: return Constants.Settings.repairFailed
        }
    }

    var versionHealthFooter: String {
        switch coordinator.repairState {
        case .idle: return Constants.Settings.idleFooter
        case .running: return Constants.Settings.runningFooter
        case .failed: return Constants.Settings.failedFooter
        }
    }

    var postMigrationStatus: String {
        switch coordinator.repairState {
        case .idle: return "Idle"
        case .running: return Constants.Settings.repairingInProgress
        case .failed: return "Failed"
        }
    }

    func hardRefresh(context: ModelContext) {
        coordinator.refreshRepairs(context: context)
    }
}
