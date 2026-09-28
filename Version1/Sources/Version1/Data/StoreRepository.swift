//
//  StoreRepository.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation
import SwiftData

@MainActor
final class StoreRepository: StoreRepositoryService {
    private let logger = AppLogger.storeRepository
    let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchContact(stableId: String) -> Contact? {
        let predicate = #Predicate<Contact> { $0.stableId == stableId }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }
    
    @discardableResult
    func createContact(from dto: ContactDTO) -> Contact {
        let newModel = Contact(from: dto)
        context.insert(newModel)
        return newModel
    }
    
    func updateContact(from dto: ContactDTO) -> Bool {
        guard let model = fetchContact(stableId: dto.stableId) else { return false }
        model.update(from: dto)
        return true
    }

    func deleteContact(from dto: ContactDTO) -> Bool {
        guard let model = fetchContact(stableId: dto.stableId) else { return false }
        context.delete(model)
        return true
    }

    func seedContacts() -> Bool {
        let existingCount = (try? context.fetchCount(FetchDescriptor<Contact>())) ?? 0
        guard existingCount == 0 else {
            logger.info("Skipping V1 seed; store already has \(existingCount) contact(s)")
            return true
        }

        logger.info("Starting V1 seeding...")
        for mock in Contact.mockList {
            context.insert(mock)
        }

        do {
            try save()
            return true
        } catch {
            logger.error("Failed to seed V1 contacts; error: \(error.localizedDescription)")
            return false
        }
    }
}
