//
//  ContactDTO.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation

struct ContactDTO: ContactPresentable {
    let stableId: String
    var firstName: String?
    var lastName: String?
    var company: String?
    var phoneNumber: String?
    var email: String?
    var birthday: Date?
    var notes: String?

    init(
        stableId: String = UUID().uuidString,
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        phoneNumber: String? = nil,
        email: String? = nil,
        birthday: Date? = nil,
        notes: String? = nil
    ) {
        self.stableId = stableId
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.phoneNumber = phoneNumber
        self.email = email
        self.birthday = birthday
        self.notes = notes
    }

    init(from model: Contact) {
        self.stableId = model.stableId
        self.firstName = model.firstName
        self.lastName = model.lastName
        self.company = model.company
        self.phoneNumber = model.phoneNumber
        self.email = model.email
        self.birthday = model.birthday
        self.notes = model.notes
    }
}
