//
//  ContactListModel.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation

public struct ContactListModel {
    public let version: Int
    public let groupedContacts: [String: [any ContactPresentable]]
    public let sortedKeys: [String]

    public init(version: Int, contacts: [any ContactPresentable]) {
        self.version = version

        let grouped = Dictionary(grouping: contacts) { contact in
            let name = Self.searchName(contact)
            guard let first = name.first else { return "#"}
            return first.isLetter ? String(first).uppercased() : "#"
        }

        self.groupedContacts = grouped.mapValues { value in
            value.sorted {
                Self.searchName($0).localizedLowercase < Self.searchName($1).localizedLowercase
            }
        }

        self.sortedKeys = groupedContacts.keys.sorted { a, b in
            (a == "#") != (b == "#") ? a != "#" : a < b
        }
    }

    public func contacts(for key: String) -> [any ContactPresentable] {
        groupedContacts[key] ?? []
    }

    public static func searchName(_ contact: any ContactPresentable) -> String {
        contact.lastName ?? contact.firstName ?? contact.company ?? ""
    }
}
