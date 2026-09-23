//
//  ContactV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

typealias ContactV2 = SchemaV2.Contact

extension SchemaV2 {
    @Model
    final class Contact: RepairableModel {
        var stableId: String = UUID().uuidString
        var repairVersion: Int = 2
        var firstName: String?
        var lastName: String?
        var company: String?
        var email: String?
        var birthday: Date?
        var notes: String?

        /// Deprecated, use phoneNumbers
        var phoneNumber: String?

        @Relationship(deleteRule: .cascade, inverse: \PhoneNumber.contact)
        var phoneNumbers: [PhoneNumber]? = []

        var asDTO: ContactDTOV2 { .init(from: self) }

        init(
            stableId: String = UUID().uuidString,
            repairVersion: Int = 2,
            firstName: String? = nil,
            lastName: String? = nil,
            company: String? = nil,
            email: String? = nil,
            birthday: Date? = nil,
            notes: String? = nil
        ) {
            self.stableId = stableId
            self.repairVersion = repairVersion
            self.firstName = firstName
            self.lastName = lastName
            self.company = company
            self.email = email
            self.birthday = birthday
            self.notes = notes
        }

        convenience init(from dto: ContactDTOV2) {
            self.init(
                stableId: dto.stableId,
                repairVersion: 2,
                firstName: dto.firstName,
                lastName: dto.lastName,
                company: dto.company,
                email: dto.email,
                birthday: dto.birthday,
                notes: dto.notes
            )
        }

        func update(from dto: ContactDTOV2) {
            if firstName != dto.firstName { firstName = dto.firstName }
            if lastName != dto.lastName { lastName = dto.lastName }
            if company != dto.company { company = dto.company }
            if email != dto.email { email = dto.email }
            if birthday != dto.birthday { birthday = dto.birthday }
            if notes != dto.notes { notes = dto.notes }
            // phone numbers updated on respective models
        }
    }
}
