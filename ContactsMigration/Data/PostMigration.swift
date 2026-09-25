//
//  PostMigration.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import OSLog
import SwiftData

enum PostMigrationError: Error, LocalizedError {
    case fetchModelFailure
    var errorDescription: String? {
        switch self {
        case .fetchModelFailure:
            return "Failed to fetch models, aborting post-migration."
        }
    }
}

@ModelActor
actor PostMigration {
    static let currentVersion = 2
    private let logger = AppLogger.postMigration

    func runIfNeeded() throws {
        let currentVersion = Self.currentVersion
        let predicate = #Predicate<V2Contact> { $0.repairVersion < currentVersion }
        let descriptor = FetchDescriptor<V2Contact>(predicate: predicate)
        let models = try fetchContacts(descriptor)

        guard models.count > 0 else {
            logger.debug("No models to repair")
            return
        }

        logger.info("Repairing \(models.count) to version 2")

        for model in models {
            migrateToV2(model)
        }
    }

    private func migrateToV2(_ model: V2Contact) {
        let version = 2

        guard model.repairVersion < version,
              let originalNumber = model.phoneNumber 
        else {
            logger.debug("Repair-noop for version 2; stableId: \(model.stableId)")
            saveToNewVersion(model, version: version)
            return
        }

        logger.debug("Replacing phoneNumber to appended PhoneNumber model on ContactV2; stableId: \(model.stableId)")
        var newNumberDTO = PhoneNumberDTO(tag: .mobile, number: originalNumber)
        model.phoneNumber = nil

        if model.phoneNumbers == nil { model.phoneNumbers = [] }
        if model.phoneNumbers?.isEmpty ?? true {
            newNumberDTO.isPrimary = true
        }

        let newNumberModel = V2Schema.PhoneNumber(from: newNumberDTO)
        modelContext.insert(newNumberModel)

        model.phoneNumbers?.append(newNumberModel)

        saveToNewVersion(model, version: version)
    }

    private func fetchContacts(_ descriptor: FetchDescriptor<V2Contact>) throws -> [V2Contact] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            logger.error("Failed to fetch models, aborting repair migration; error: \(error.localizedDescription)")
            throw PostMigrationError.fetchModelFailure
        }
    }

    private func saveToNewVersion(_ model: V2Contact, version: Int) {
        let previousVersion = model.repairVersion
        model.repairVersion = version

        do {
            try modelContext.save()
        } catch {
            logger.error("Failed to save: stableId \(model.stableId); fromVersion \(previousVersion) toVersion \(version); error: \(error.localizedDescription)")
            modelContext.rollback()
        }
    }
}
