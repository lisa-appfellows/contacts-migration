//
//  StoreRepositoryService.swift
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
            return Constants.Store.saveContextFailureRollback
        }
    }
}

@MainActor
public protocol StoreRepositoryService {
    var context: ModelContext { get }
}

extension StoreRepositoryService {
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
}
