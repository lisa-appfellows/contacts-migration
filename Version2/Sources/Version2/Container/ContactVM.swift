//
//  ContactVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

@Observable
final class ContactVM {
    let isNewContact: Bool
    var navTitle: String {
        isNewContact ? CoreUI.Constants.Editor.newContact : ""
    }

    var stableId: String
    var repairVersion: Int

    var firstName: String
    var lastName: String
    var company: String

    let phoneLimit: Int? = nil
    var phoneNumbers: [PhoneNumberDTO]

    let emailLimit = 1
    var emails: [String]

    let birthdayLimit = 1
    var birthdays: [Date]

    var notes: String

    var canEdit: Bool {
        repairVersion == PostMigration.currentVersion
    }

    var dto: ContactDTO {
        .init(
            stableId: stableId,
            repairVersion: repairVersion,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            company: company.isEmpty ? nil : company,
            email: emails.first { !$0.isEmpty },
            birthday: birthdays.first,
            notes: notes.isEmpty ? nil : notes,
            phoneNumbers: phoneNumbers.filter { !$0.number.isEmpty }
        )
    }

    init(
        isNewContact: Bool = true,
        stableId: String = UUID().uuidString,
        repairVersion: Int = PostMigration.currentVersion,
        firstName: String = "",
        lastName: String = "",
        company: String = "",
        phoneNumbers: [PhoneNumberDTO] = [],
        emails: [String] = [],
        birthdays: [Date] = [],
        notes: String = ""
    ) {
        self.isNewContact = isNewContact
        self.stableId = stableId
        self.repairVersion = repairVersion
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.phoneNumbers = phoneNumbers
        self.emails = emails
        self.birthdays = birthdays
        self.notes = notes
    }

    convenience init(from dto: ContactDTO?) {
        guard let dto else {
            self.init()
            return
        }

        self.init(
            isNewContact: false,
            stableId: dto.stableId,
            repairVersion: dto.repairVersion,
            firstName: dto.firstName ?? "",
            lastName: dto.lastName ?? "",
            company: dto.company ?? "",
            phoneNumbers: dto.phoneNumbers,
            emails: dto.email != nil ? [dto.email ?? ""] : [],
            birthdays: dto.birthday != nil ? [dto.birthday ?? .now] : [],
            notes: dto.notes ?? ""
        )
    }

    init(from model: Contact) {
        self.isNewContact = false
        self.stableId = model.stableId
        self.repairVersion = model.repairVersion
        self.firstName = model.firstName ?? ""
        self.lastName = model.lastName ?? ""
        self.company = model.company ?? ""
        self.phoneNumbers = model.phoneNumbers?.map { $0.asDTO } ?? []
        self.emails = model.email != nil ? [model.email ?? ""] : []
        self.birthdays = model.birthday != nil ? [model.birthday ?? .now] : []
        self.notes = model.notes ?? ""
    }
}
