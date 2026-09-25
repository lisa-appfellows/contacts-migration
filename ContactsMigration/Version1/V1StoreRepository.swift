//
//  V1StoreRepository.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

@MainActor
final class V1StoreRepository: StoreRepository {
    let context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    func createContact(from dto: V1ContactDTO) -> V1Contact {
        let newModel = V1Contact(from: dto)
        context.insert(newModel)
        return newModel
    }

    func updateContact(_ model: V1Contact, from dto: V1ContactDTO) {
        model.update(from: dto)
    }
}
