//
//  StoreRepository.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation
import SwiftData

public enum StoreRepositoryError: Error, LocalizedError {
    case saveContextFailureRollback
    public var errorDescription: String? {
        switch self {
        case .saveContextFailureRollback:
            return "Failed to save context, rolling back."
        }
    }
}

@MainActor
public protocol StoreRepository {
    var context: ModelContext { get }
}

extension StoreRepository {
    public func save() throws {
        do {
            try context.save()
        } catch {
            AppLogger.storeRepository.error("Failed to save context, rolling back; error: \(error.localizedDescription)")
            discard()
            throw StoreRepositoryError.saveContextFailureRollback
        }
    }

    public func discard() {
        context.rollback()
    }

    public func delete<Model: PersistentModel>(_ model: Model) {
        context.delete(model)
    }
}
