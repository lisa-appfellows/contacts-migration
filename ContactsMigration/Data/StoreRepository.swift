//
//  StoreRepository.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Foundation
import OSLog
import SwiftData

protocol RepairableModel: PersistentModel {
    var repairVersion: Int { get set }
}

enum StoreRepositoryError: Error, LocalizedError {
    case saveContextFailureRollback
    var errorDescription: String? {
        switch self {
        case .saveContextFailureRollback:
            return "Failed to save context, rolling back."
        }
    }
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
            AppLogger.storeRepository.error("Failed to save context, rolling back; error: \(error.localizedDescription)")
            discard()
            throw StoreRepositoryError.saveContextFailureRollback
        }
    }

    func discard() {
        context.rollback()
    }

    func delete<Model: PersistentModel>(_ model: Model) {
        context.delete(model)
    }
}
