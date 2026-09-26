//
//  ContactPresentationModel.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation

public struct ContactPresentationModel {
    public let contact: any ContactPresentable

    public init(contact: any ContactPresentable) {
        self.contact = contact
    }

    public var firstInitial: String? { letter(isFirstName: true) }
    public var lastInitial: String? { letter(isFirstName: false) }
    public var isBusiness: Bool {
        contact.firstName == nil &&
        contact.lastName == nil &&
        contact.company != nil
    }

    public var presentationName: String {
        if let firstName = contact.firstName, let lastName = contact.lastName {
            return firstName + " " + lastName
        }

        if let firstName = contact.firstName { return firstName }
        if let lastName = contact.lastName { return lastName }
        if let companyName = contact.company { return companyName }

        return ""
    }

    public func letter(isFirstName: Bool) -> String? {
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
