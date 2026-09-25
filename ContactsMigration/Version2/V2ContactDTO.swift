//
//  V2ContactDTO.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation

struct V2ContactDTO {
    let stableId: String
    var firstName: String?
    var lastName: String?
    var company: String?
    var email: String?
    var birthday: Date?
    var notes: String?
    
    private(set) var phoneNumbers: [PhoneNumberDTO]
    
    var primaryNumber: PhoneNumberDTO? {
        phoneNumbers.first(where: { $0.isPrimary }) ??
        phoneNumbers.first(where: { $0.tag == .mobile }) ??
        phoneNumbers.first
    }
    
    init(
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        email: String? = nil,
        birthday: Date? = nil,
        notes: String? = nil,
        phoneNumbers: [PhoneNumberDTO] = []
    ) {
        self.stableId = UUID().uuidString
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.email = email
        self.birthday = birthday
        self.notes = notes
        self.phoneNumbers = phoneNumbers
    }
    
    init(from model: V2Contact) {
        self.stableId = model.stableId
        self.firstName = model.firstName
        self.lastName = model.lastName
        self.company = model.company
        self.email = model.email
        self.birthday = model.birthday
        self.notes = model.notes
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
