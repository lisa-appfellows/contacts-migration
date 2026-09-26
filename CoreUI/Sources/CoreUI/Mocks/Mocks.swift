//
//  Mocks.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

#if DEBUG
import Foundation

extension ContactListModel {
    public static func mock(version: Int) -> ContactListModel {
        .init(version: version, contacts: MockContact.contacts)
    }
}

extension ContactPresentationModel {
    public static func mock(contact: MockContact = .contacts[0]) -> ContactPresentationModel {
        .init(contact: contact)
    }
}
#endif
