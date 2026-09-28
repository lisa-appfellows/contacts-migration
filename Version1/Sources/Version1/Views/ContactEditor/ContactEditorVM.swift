//
//  ContactEditorVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Core
import CoreUI
import SwiftUI

enum EditAlert {
    case saveFailure(ContactDTO, isNewContact: Bool)
    case deleteFailure(ContactDTO)
    var editFailure: EditFailure {
        switch self {
        case .saveFailure: return .save
        case .deleteFailure: return .delete
        }
    }
}

enum EditorFinishAction {
    case saved
    case deleted
}

@MainActor
@Observable
final class ContactEditorVM {
    let storeRepo: StoreRepository

    var finishAction: EditorFinishAction?
    var editAlert: EditAlert?

    init(storeRepo: StoreRepository) {
        self.storeRepo = storeRepo
    }

    func navTitle(isNewContact: Bool) -> String {
        isNewContact ? CoreUI.Constants.Editor.newContact : ""
    }

    func save(_ dto: ContactDTO, isNewContact: Bool) {
        editAlert = nil
        var didSucceed = false

        if isNewContact {
            storeRepo.createContact(from: dto)
            didSucceed = save(to: storeRepo)
        } else {
            didSucceed = storeRepo.updateContact(from: dto) && save(to: storeRepo)
        }

        guard didSucceed else {
            editAlert = .saveFailure(dto, isNewContact: isNewContact)
            return
        }

        finishAction = .saved
    }

    func delete(_ dto: ContactDTO)  {
        editAlert = nil

        guard storeRepo.deleteContact(from: dto), save(to: storeRepo) else {
            editAlert = .deleteFailure(dto)
            return
        }

        finishAction = .deleted
    }

    func tryAgain(_ alert: EditAlert) {
        editAlert = nil
        switch alert {
        case .saveFailure(let dto, let isNewContact):
            save(dto, isNewContact: isNewContact)
        case .deleteFailure(let dto):
            delete(dto)
        }
    }

    private func save(to storeRepo: StoreRepository) -> Bool {
        var saveAttempts = 0
        while saveAttempts < 3 {
            do {
                try storeRepo.save()
                return true
            } catch {
                saveAttempts += 1
            }
        }
        return false
    }
}
