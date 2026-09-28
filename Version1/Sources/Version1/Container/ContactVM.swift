//
//  ContactVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

@Observable
final class ContactVM {
    let isNewContact: Bool

    var stableId: String

    var firstName: String
    var lastName: String
    var company: String

    let phoneLimit = 1
    var phoneNumbers: [String]

    let emailLimit = 1
    var emails: [String]

    let birthdayLimit = 1
    var birthdays: [Date]

    var notes: String

    var dto: ContactDTO {
        .init(
            stableId: stableId,
            firstName: firstName.isEmpty ? nil : firstName,
            lastName: lastName.isEmpty ? nil : lastName,
            company: company.isEmpty ? nil : company,
            phoneNumber: phoneNumbers.first { !$0.isEmpty },
            email: emails.first { !$0.isEmpty },
            birthday: birthdays.first,
            notes: notes.isEmpty ? nil : notes
        )
    }

    init(
        isNewContact: Bool = true,
        stableId: String = UUID().uuidString,
        firstName: String = "",
        lastName: String = "",
        company: String = "",
        phoneNumbers: [String] = [],
        emails: [String] = [],
        birthdays: [Date] = [],
        notes: String = ""
    ) {
        self.isNewContact = isNewContact
        self.stableId = stableId
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
            firstName: dto.firstName ?? "",
            lastName: dto.lastName ?? "",
            company: dto.company ?? "",
            phoneNumbers: dto.phoneNumber != nil ? [dto.phoneNumber ?? ""] : [],
            emails: dto.email != nil ? [dto.email ?? ""] : [],
            birthdays: dto.birthday != nil ? [dto.birthday ?? .now] : [],
            notes: dto.notes ?? ""
        )
    }
}
