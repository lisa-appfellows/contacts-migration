//
//  V2ContactVM.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

@Observable
final class V2ContactVM {
    let isNewContact: Bool
    var navTitle: String {
        isNewContact ? "New Contact" : ""
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

    init(
        isNewContact: Bool = true,
        stableId: String = UUID().uuidString,
        repairVersion: Int = 2,
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

    init(from model: V2Contact) {
        self.isNewContact = false
        self.stableId = model.stableId
        self.repairVersion = model.repairVersion
        self.firstName = model.firstName ?? ""
        self.lastName  = model.lastName ?? ""
        self.company = model.company ?? ""
        self.phoneNumbers = model.phoneNumbers?.map { $0.asDTO } ?? []
        self.emails = model.email != nil ? [model.email ?? ""] : []
        self.birthdays = model.birthday != nil ? [model.birthday ?? .now] : []
        self.notes = model.notes ?? ""
    }

    func removeBirthdays(_ indexSet: IndexSet) {
        birthdays.remove(atOffsets: indexSet)
    }
}
