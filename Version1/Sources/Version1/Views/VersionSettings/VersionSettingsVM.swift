//
//  VersionSettingsVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Core
import SwiftUI

@MainActor
@Observable
final class VersionSettingsVM {
    let storeRepo: StoreRepository
    var versionState: VersionState

    /// Mirrors store emptiness for the seed UI; updated locally after a successful seed.
    var isStoreEmpty: Bool
    private var seedingSucceeded: Bool?

    /// Local UI flag so Settings can show a spinner before the app swaps containers.
    private(set) var isMigrating = false

    var versionIsHealthy: Bool {
        versionState.containerState == .healthy
    }

    init(
        storeRepo: StoreRepository,
        versionState: VersionState = .init(),
        isStoreEmpty: Bool
    ) {
        self.storeRepo = storeRepo
        self.versionState = versionState
        self.isStoreEmpty = isStoreEmpty
    }

    func applyVersionState(_ state: VersionState) {
        versionState = state
    }

    var seedFooter: String {
        guard let seedingSucceeded else {
            return Constants.Settings.seedFooter
        }

        return seedingSucceeded ? Constants.Settings.seedingSucceeded : Constants.Settings.seedingFailed
    }

    var versionHealth: String {
        versionIsHealthy ? Constants.Settings.healthy : Constants.Settings.migrationFailed
    }

    var versionHealthFooter: String {
        versionIsHealthy ?
        Constants.Settings.healthyFooter :
        Constants.Settings.failedFooter
    }

    var migrateTitle: String {
        versionIsHealthy ? Constants.Settings.migrateToV2 : Constants.Settings.retryV2Migration
    }

    var migrateSymbol: String {
        versionIsHealthy ? Constants.Settings.migrateHealthySymbol : Constants.Settings.migrateFailedSymbol
    }

    var migrateFooter: String {
        if isMigrating {
            return Constants.Settings.migratingDescription
        }
        return versionIsHealthy
            ? Constants.Settings.migrateHealthyDescription
            : Constants.Settings.migrateFailedDescription
    }

    func beginMigrate() {
        isMigrating = true
    }

    func seed() {
        guard isStoreEmpty else { return }

        seedingSucceeded = nil

        guard storeRepo.seedContacts() else {
            seedingSucceeded = false
            return
        }

        isStoreEmpty = false
        seedingSucceeded = true
    }
}
