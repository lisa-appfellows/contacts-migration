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
    var repairVersion: Int
    var firstName: String?
    var lastName: String?
    var company: String?
    var email: String?
    var birthday: Date?
    var notes: String?

    /// Deprecated migration source string. Not part of `phoneNumbers` — views
    /// may render it as a display-only row until `PostMigration` clears it.
    var phoneNumber: String?

    private(set) var phoneNumbers: [PhoneNumberDTO]

    var isBehindOnRepair: Bool {
        repairVersion < PostMigration.currentVersion
    }

    /// Legacy string to show on detail when it isn't already represented in the relationship.
    var displayLegacyPhoneNumber: String? {
        guard let legacy = phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines),
              !legacy.isEmpty
        else {
            return nil
        }
        if phoneNumbers.contains(where: { $0.number == legacy }) {
            return nil
        }
        return legacy
    }

    var primaryNumber: PhoneNumberDTO? {
        phoneNumbers.first(where: { $0.isPrimary }) ??
        phoneNumbers.first(where: { $0.tag == .mobile }) ??
        phoneNumbers.first
    }

    init(
        stableId: String = UUID().uuidString,
        repairVersion: Int = PostMigration.currentVersion,
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        email: String? = nil,
        birthday: Date? = nil,
        notes: String? = nil,
        phoneNumber: String? = nil,
        phoneNumbers: [PhoneNumberDTO] = []
    ) {
        self.stableId = stableId
        self.repairVersion = repairVersion
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.email = email
        self.birthday = birthday
        self.notes = notes
        self.phoneNumber = phoneNumber
        self.phoneNumbers = phoneNumbers
    }

    init(from model: Contact) {
        self.stableId = model.stableId
        self.repairVersion = model.repairVersion
        self.firstName = model.firstName
        self.lastName = model.lastName
        self.company = model.company
        self.email = model.email
        self.birthday = model.birthday
        self.notes = model.notes
        self.phoneNumber = model.phoneNumber
        self.phoneNumbers = model.phoneNumbers?.map { $0.asDTO } ?? []
    }

    mutating func addPhoneNumber(_ phDto: PhoneNumberDTO) {
        if phDto.isPrimary {
            for (index, phoneNumber) in phoneNumbers.enumerated() {
                if phoneNumber.isPrimary {
                    phoneNumbers[index].isPrimary = false
                }
            }
        }

        phoneNumbers.append(phDto)
    }
}
