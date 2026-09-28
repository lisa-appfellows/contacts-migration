//
//  StoreRepository.swift
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
            return Constants.Store.repairStateBehind(
                version: version,
                currentVersion: PostMigration.currentVersion
            )
        }
    }
}

@MainActor
final class StoreRepository: StoreRepositoryService {
    let context: ModelContext
    init(context: ModelContext) {
        self.context = context
    }

    func isUpToDateOnRepair<Model: RepairableModel>(_ model: Model) -> Bool {
        model.repairVersion == PostMigration.currentVersion
    }

    func fetchContact(stableId: String) -> Contact? {
        let predicate = #Predicate<Contact> { $0.stableId == stableId }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    @discardableResult
    func createContact(from dto: ContactDTO) -> Contact {
        let newModel = V2Schema.Contact(from: dto)
        context.insert(newModel)

        for phDto in dto.phoneNumbers {
            let newPhModel = V2Schema.PhoneNumber(from: phDto)
            newPhModel.contact = newModel
            context.insert(newPhModel)
        }

        return newModel
    }

    func updateContact(_ model: Contact, from dto: ContactDTO) throws {
        guard isUpToDateOnRepair(model) else {
            throw RepairStateError.repairStateBehind(version: model.repairVersion)
        }

        model.update(from: dto)
        try updatePhoneNumberList(dto.phoneNumbers, on: model)
    }

    /// DTO-based update for editor orchestration (V1 pattern). Returns false if missing or repair-behind.
    func updateContact(from dto: ContactDTO) -> Bool {
        guard let model = fetchContact(stableId: dto.stableId) else { return false }
        do {
            try updateContact(model, from: dto)
            return true
        } catch {
            return false
        }
    }

    func deleteContact(_ model: Contact) {
        for phone in model.phoneNumbers ?? [] {
            context.delete(phone)
        }
        model.phoneNumbers = []
        context.delete(model)
    }

    /// DTO-based delete for editor orchestration (V1 pattern).
    func deleteContact(from dto: ContactDTO) -> Bool {
        guard let model = fetchContact(stableId: dto.stableId) else { return false }
        deleteContact(model)
        return true
    }

    @discardableResult
    func createPhoneNumber(from dto: PhoneNumberDTO) -> PhoneNumber {
        let newModel = PhoneNumber(from: dto)
        context.insert(newModel)
        return newModel
    }

    func addPhoneNumberDTO(_ phDto: PhoneNumberDTO, to contactModel: Contact) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        let newPhModel = PhoneNumber(from: phDto)
        newPhModel.contact = contactModel
        context.insert(newPhModel)
    }

    func updatePhoneNumber(_ model: PhoneNumber, from dto: PhoneNumberDTO) {
        model.update(from: dto)
    }

    func updatePhoneNumberList(_ dtoList: [PhoneNumberDTO], on contactModel: Contact) throws {
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

    func removePhoneNumber(_ phModel: PhoneNumber, at index: Int, from contactModel: Contact) throws {
        guard isUpToDateOnRepair(contactModel) else {
            throw RepairStateError.repairStateBehind(version: contactModel.repairVersion)
        }

        contactModel.phoneNumbers?.remove(at: index)
        context.delete(phModel)
    }
}

