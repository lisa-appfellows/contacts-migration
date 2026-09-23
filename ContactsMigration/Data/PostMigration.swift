//
//  PostMigration.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import SwiftData

@ModelActor
actor PostMigration {
    static let currentVersion = 2

    func runIfNeeded() {
        let currentVersion = Self.currentVersion
        let predicate = #Predicate<ContactV2> { $0.repairVersion < currentVersion }
        let descriptor = FetchDescriptor<ContactV2>(predicate: predicate)
        let models = fetchContacts(descriptor)

        guard models.count > 0 else { return }

        for model in models {
            migrateToV2(model)
        }
    }

    private func migrateToV2(_ model: ContactV2) {
        let version = 2

        guard model.repairVersion < version,
              let originalNumber = model.phoneNumber 
        else {
            model.repairVersion = version
            save(model)
            return
        }

        var newNumberDTO = PhoneNumberDTOV2(tag: .mobile, number: originalNumber)
        model.phoneNumber = nil

        if model.phoneNumbers == nil { model.phoneNumbers = [] }
        if model.phoneNumbers?.isEmpty ?? true {
            newNumberDTO.isPrimary = true
        }

        let newNumberModel = SchemaV2.PhoneNumber(from: newNumberDTO)
        modelContext.insert(newNumberModel)

        model.phoneNumbers?.append(newNumberModel)
        model.repairVersion = version

        save(model)
    }

    private func fetchContacts(_ descriptor: FetchDescriptor<ContactV2>) -> [ContactV2] {
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch models: \(error.localizedDescription)")
            return []
        }
    }

    private func save(_ model: ContactV2) {
        do {
            try modelContext.save()
        } catch {
            // TODO: Set up logging
            print("Failed to save: stableId \(model.stableId); fromVersion \(model.repairVersion) toVersion \(Self.currentVersion); error: \(error.localizedDescription)")
            modelContext.rollback()
        }
    }
}
