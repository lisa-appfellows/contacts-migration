//
//  V1ContactVM.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

@Observable
final class V1ContactVM {
    let isNewContact: Bool
    var navTitle: String {
        isNewContact ? "New Contact" : ""
    }

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

    init(from model: V1Contact) {
        self.isNewContact = false
        self.stableId = model.stableId
        self.firstName = model.firstName ?? ""
        self.lastName  = model.lastName ?? ""
        self.company = model.company ?? ""
        self.phoneNumbers = model.phoneNumber != nil ? [model.phoneNumber ?? ""] : []
        self.emails = model.email != nil ? [model.email ?? ""] : []
        self.birthdays = model.birthday != nil ? [model.birthday ?? .now] : []
        self.notes = model.notes ?? ""
    }
}

