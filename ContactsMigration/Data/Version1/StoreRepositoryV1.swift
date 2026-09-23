//
//  StoreRepositoryV1.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

@MainActor
final class StoreRepositoryV1: StoreRepository {
    let context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func createContact(from dto: ContactDTOV1) -> ContactV1 {
        let newModel = ContactV1(from: dto)
        context.insert(newModel)
        return newModel
    }

    func updateContact(_ model: ContactV1, from dto: ContactDTOV1) {
        model.update(from: dto)
    }
}
