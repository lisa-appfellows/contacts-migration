//
//  PostMigration.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation
import OSLog
import SwiftData

enum PostMigrationError: Error, LocalizedError {
    case fetchModelFailure
    case saveFailure(stableId: String)

    var errorDescription: String? {
        switch self {
        case .fetchModelFailure:
            return Constants.PostMigration.fetchModelFailure
        case .saveFailure(let stableId):
            return "Failed to save repair for contact: \(stableId)"
        }
    }
}

/// Runs on the caller's `ModelContext` (typically the main/UI context).
/// Avoid `@ModelActor` here — cross-context saves while the main context is alive
/// have been duplicating `PhoneNumber` relationships on device.
enum PostMigration {
    static let currentVersion = 2
    private static let logger = AppLogger.postMigration

    @MainActor
    static func runIfNeeded(context: ModelContext) throws {
        let currentVersion = currentVersion
        let predicate = #Predicate<Contact> { $0.repairVersion < currentVersion }
        let descriptor = FetchDescriptor<Contact>(predicate: predicate)
        let models = try fetchContacts(descriptor, context: context)

        if models.isEmpty {
            logger.debug("No models behind on repair")
        } else {
            logger.info("Repairing \(models.count) to version 2")
            for model in models {
                try migrateToV2(model, context: context, save: false)
            }
        }

        // Heal any already-migrated contacts that still carry duplicate phones
        // from earlier cross-context merges.
        let all = try fetchContacts(FetchDescriptor<Contact>(), context: context)
        for model in all {
            dedupePhoneNumbers(on: model, context: context)
        }

        do {
            try context.save()
        } catch {
            logger.error(
                "Failed to save post-migration batch; error: \(error.localizedDescription)"
            )
            context.rollback()
            throw PostMigrationError.saveFailure(stableId: "batch")
        }
    }

    @MainActor
    private static func migrateToV2(
        _ model: Contact,
        context: ModelContext,
        save: Bool
    ) throws {
        let version = currentVersion
        guard model.repairVersion < version else { return }

        let legacy = model.phoneNumber?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        model.phoneNumber = nil

        if let legacy, !legacy.isEmpty {
            materializeLegacyPhoneIfNeeded(legacy, on: model, context: context)
        } else {
            logger.debug("Repair-noop for version 2; stableId: \(model.stableId)")
        }

        dedupePhoneNumbers(on: model, context: context)
        model.repairVersion = version

        guard save else { return }
        do {
            try context.save()
        } catch {
            logger.error(
                "Failed to save: stableId \(model.stableId); toVersion \(version); error: \(error.localizedDescription)"
            )
            context.rollback()
            throw PostMigrationError.saveFailure(stableId: model.stableId)
        }
    }

    /// Match `StoreRepository.addPhoneNumberDTO`: insert + set inverse.
    /// Do **not** copy/reassign the `phoneNumbers` array — that pattern has
    /// duplicated relationship rows under SwiftData.
    @MainActor
    private static func materializeLegacyPhoneIfNeeded(
        _ legacy: String,
        on model: Contact,
        context: ModelContext
    ) {
        let existing = model.phoneNumbers ?? []
        if existing.contains(where: { normalized($0.number) == legacy }) {
            logger.debug(
                "Legacy phone already in relationship; clearing string only; stableId: \(model.stableId)"
            )
            return
        }

        logger.debug(
            "Materializing phoneNumber into PhoneNumber relationship; stableId: \(model.stableId)"
        )
        var newNumberDTO = PhoneNumberDTO(tag: .mobile, number: legacy)
        if existing.isEmpty {
            newNumberDTO.isPrimary = true
        }
        let newNumberModel = PhoneNumber(from: newNumberDTO)
        newNumberModel.contact = model
        context.insert(newNumberModel)
    }

    @MainActor
    private static func dedupePhoneNumbers(on model: Contact, context: ModelContext) {
        guard let phones = model.phoneNumbers, phones.count > 1 else { return }

        var seen = Set<String>()
        var keep: [PhoneNumber] = []
        var removals: [PhoneNumber] = []

        for phone in phones {
            let key = normalized(phone.number)
            if key.isEmpty || seen.contains(key) {
                removals.append(phone)
            } else {
                seen.insert(key)
                keep.append(phone)
            }
        }

        guard !removals.isEmpty else { return }
        logger.info(
            "Removing \(removals.count) duplicate phone(s); stableId: \(model.stableId)"
        )

        // Delete first, then assign keepers — avoid array copy/reassign with
        // still-attached duplicates.
        for phone in removals {
            phone.contact = nil
            context.delete(phone)
        }
        model.phoneNumbers = keep
    }

    private static func normalized(_ number: String?) -> String {
        (number ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    @MainActor
    private static func fetchContacts(
        _ descriptor: FetchDescriptor<Contact>,
        context: ModelContext
    ) throws -> [Contact] {
        do {
            return try context.fetch(descriptor)
        } catch {
            logger.error(
                "Failed to fetch models, aborting repair migration; error: \(error.localizedDescription)"
            )
            throw PostMigrationError.fetchModelFailure
        }
    }
}
