//
//  V2StoreRepository.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
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
final class V2StoreRepository: StoreRepository {
    let context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    func isUpToDateOnRepair<Model: RepairableModel>(_ model: Model) -> Bool {
        model.repairVersion == PostMigration.currentVersion
    }

    @discardableResult
    func createContact(from dto: V2ContactDTO) -> V2Contact {
        let newModel = V2Schema.Contact(from: dto)
        context.insert(newModel)

        for phDto in dto.phoneNumbers {
            let newPhModel = V2Schema.PhoneNumber(from: phDto)
            context.insert(newPhModel)
            newModel.phoneNumbers?.append(newPhModel)
        }

        return newModel
    }

    func updateContact(_ model: V2Contact, from dto: V2ContactDTO) throws {
        guard isUpToDateOnRepair(model) else {
            throw RepairStateError.repairStateBehind(version: model.repairVersion)
        }

        model.update(from: dto)
        try updatePhoneNumberList(dto.phoneNumbers, on: model)
    }

    func deleteContact(_ model: V2Contact) {
        for phone in model.phoneNumbers ?? [] {
            context.delete(phone)
        }
        model.phoneNumbers = []
        context.delete(model)
    }

    @discardableResult
    func createPhoneNumber(from dto: PhoneNumberDTO) -> PhoneNumber {
        let newModel = PhoneNumber(from: dto)
        context.insert(newModel)
        return newModel
    }

    func addPhoneNumberDTO(_ phDto: PhoneNumberDTO, to contactModel: V2Contact) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        let newPhModel = createPhoneNumber(from: phDto)
        contactModel.phoneNumbers?.append(newPhModel)
    }

    func updatePhoneNumber(_ model: PhoneNumber, from dto: PhoneNumberDTO) {
        model.update(from: dto)
    }

    func updatePhoneNumberList(_ dtoList: [PhoneNumberDTO], on contactModel: V2Contact) throws {
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

    func removePhoneNumber(_ phModel: PhoneNumber, at index: Int, from contactModel: V2Contact) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        contactModel.phoneNumbers?.remove(at: index)
        context.delete(phModel)
    }
}

