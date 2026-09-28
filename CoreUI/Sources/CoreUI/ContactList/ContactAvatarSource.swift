//
//  ContactAvatarSource.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Core
import Foundation

/// Immutable name fields for avatar display (e.g. editor snapshot at open).
public struct ContactAvatarSource: ContactPresentable {
    public let stableId: String
    public let firstName: String?
    public let lastName: String?
    public let company: String?

    public init(
        stableId: String = "",
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil
    ) {
        self.stableId = stableId
        self.firstName = Self.nilIfEmpty(firstName)
        self.lastName = Self.nilIfEmpty(lastName)
        self.company = Self.nilIfEmpty(company)
    }

    public static let placeholder = ContactAvatarSource()

    public init(contact: any ContactPresentable) {
        self.init(
            stableId: contact.stableId,
            firstName: contact.firstName,
            lastName: contact.lastName,
            company: contact.company
        )
    }

    private static func nilIfEmpty(_ value: String?) -> String? {
        guard let value, !value.isEmpty else { return nil }
        return value
    }
}
