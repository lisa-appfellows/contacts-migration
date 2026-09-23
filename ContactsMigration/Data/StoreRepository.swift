//
//  StoreRepository.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import SwiftData

protocol RepairableModel: PersistentModel {
    var repairVersion: Int { get set }
}

@MainActor
protocol StoreRepository {
    var context: ModelContext { get }
}

extension StoreRepository {
    func save() throws {
        do {
            try context.save()
        } catch {
            print("Failed to save")
            discard()
            throw error
        }
    }

    func discard() {
        context.rollback()
    }

    func delete<Model: PersistentModel>(_ model: Model) {
        context.delete(model)
    }
}
