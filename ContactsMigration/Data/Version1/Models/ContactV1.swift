//
//  ContactV1.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

typealias ContactV1 = SchemaV1.Contact

extension SchemaV1 {
    @Model
    final class Contact: RepairableModel {
        var stableId: String = UUID().uuidString
        var repairVersion: Int = 1
        var firstName: String?
        var lastName: String?
        var company: String?
        var phoneNumber: String?
        var email: String?
        var birthday: Date?
        var notes: String?

        var asDTO: ContactDTOV1 { .init(from: self) }

        init(
            stableId: String = UUID().uuidString,
            repairVersion: Int = 1,
            firstName: String? = nil,
            lastName: String? = nil,
            company: String? = nil,
            phoneNumber: String? = nil,
            email: String? = nil,
            birthday: Date? = nil,
            notes: String? = nil
        ) {
            self.stableId = stableId
            self.repairVersion = repairVersion
            self.firstName = firstName
            self.lastName = lastName
            self.company = company
            self.phoneNumber = phoneNumber
            self.email = email
            self.birthday = birthday
            self.notes = notes
        }

        convenience init(from dto: ContactDTOV1) {
            self.init(
                stableId: dto.stableId,
                firstName: dto.firstName,
                lastName: dto.lastName,
                company: dto.company,
                phoneNumber: dto.phoneNumber,
                email: dto.email,
                birthday: dto.birthday,
                notes: dto.notes
            )
        }

        func update(from dto: ContactDTOV1) {
            if firstName != dto.firstName { firstName = dto.firstName }
            if lastName != dto.lastName { lastName = dto.lastName }
            if company != dto.company { company = dto.company }
            if phoneNumber != dto.phoneNumber { phoneNumber = dto.phoneNumber}
            if email != dto.email { email = dto.email }
            if birthday != dto.birthday { birthday = dto.birthday }
            if notes != dto.notes { notes = dto.notes }
        }
    }
}
