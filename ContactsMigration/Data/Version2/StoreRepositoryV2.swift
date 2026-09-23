//
//  StoreRepositoryV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

enum RepairStateError: Error, LocalizedError {
    case repairStateBehind(version: Int)
    var errorDescription: String? {
        switch self {
        case .repairStateBehind(let version):
            return "Cannot update, repairVersion \(version) is behind \(PostMigration.currentVersion)"
        }
    }
}

@MainActor
final class StoreRepositoryV2: StoreRepository {
    let context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    func isUpToDateOnRepair<Model: RepairableModel>(_ model: Model) -> Bool {
        model.repairVersion == PostMigration.currentVersion
    }

    @discardableResult
    func createContact(from dto: ContactDTOV2) -> ContactV2 {
        let newModel = SchemaV2.Contact(from: dto)
        context.insert(newModel)

        for phDto in dto.phoneNumbers {
            let newPhModel = SchemaV2.PhoneNumber(from: phDto)
            context.insert(newPhModel)
            newModel.phoneNumbers?.append(newPhModel)
        }

        return newModel
    }

    func updateContact(_ model: ContactV2, from dto: ContactDTOV2) throws {
        guard isUpToDateOnRepair(model) else {
            throw RepairStateError.repairStateBehind(version: model.repairVersion)
        }

        model.update(from: dto)
        try updatePhoneNumberList(dto.phoneNumbers, on: model)
    }

    func deleteContact(_ model: ContactV2) {
        for phone in model.phoneNumbers ?? [] {
            context.delete(phone)
        }
        model.phoneNumbers = []
        context.delete(model)
    }

    @discardableResult
    func createPhoneNumber(from dto: PhoneNumberDTOV2) -> PhoneNumberV2 {
        let newModel = PhoneNumberV2(from: dto)
        context.insert(newModel)
        return newModel
    }

    func addPhoneNumberDTO(_ phDto: PhoneNumberDTOV2, to contactModel: ContactV2) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        let newPhModel = createPhoneNumber(from: phDto)
        contactModel.phoneNumbers?.append(newPhModel)
    }

    func updatePhoneNumber(_ model: PhoneNumberV2, from dto: PhoneNumberDTOV2) {
        model.update(from: dto)
    }

    func updatePhoneNumberList(_ dtoList: [PhoneNumberDTOV2], on contactModel: ContactV2) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        let dtoNumberMap = Dictionary(
            dtoList.map { ($0.id, $0) },
            uniquingKeysWith: { first, _ in first }
        )

        if contactModel.phoneNumbers == nil { contactModel.phoneNumbers = [] }
        var observedPhDtoIds = Set<String>()

        for index in stride(from: ((contactModel.phoneNumbers?.count ?? 0) - 1), through: 0, by: -1) {
            guard let phModel = contactModel.phoneNumbers?[index] else { continue }

            if let phDto = dtoNumberMap[phModel.id] {
                phModel.update(from: phDto)
                observedPhDtoIds.insert(phDto.id)
            } else {
                try removePhoneNumber(phModel, at: index, from: contactModel)
            }
        }

        for (id, phDto) in dtoNumberMap {
            if !observedPhDtoIds.contains(id) {
                try addPhoneNumberDTO(phDto, to: contactModel)
            }
        }
    }

    func removePhoneNumber(_ phModel: PhoneNumberV2, at index: Int, from contactModel: ContactV2) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        contactModel.phoneNumbers?.remove(at: index)
        context.delete(phModel)
    }
}
