//
//  ContactPresentationModel.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import Foundation

struct ContactPresentationModel {
    let contact: any ContactPresentable

    init(contact: any ContactPresentable) {
        self.contact = contact
    }

    var firstInitial: String? { letter(isFirstName: true) }
    var lastInitial: String? { letter(isFirstName: false) }
    var isBusiness: Bool {
        contact.firstName == nil &&
        contact.lastName == nil &&
        contact.company != nil
    }

    var presentationName: String {
        if let firstName = contact.firstName, let lastName = contact.lastName {
            return firstName + " " + lastName
        }

        if let firstName = contact.firstName { return firstName }
        if let lastName = contact.lastName { return lastName }
        if let companyName = contact.company { return companyName }

        return ""
    }

    func letter(isFirstName: Bool) -> String? {
        guard let letter = isFirstName ?
                contact.firstName?.first :
                contact.lastName?.first,
              letter.isLetter 
        else {
            return nil
        }

        return String(letter).uppercased()
    }
}
