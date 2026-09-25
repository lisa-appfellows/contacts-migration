//
//  ContactListModel.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import Foundation

protocol ContactPresentable {
    var stableId: String { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var company: String? { get }
}

struct ContactListModel {
    let groupedContacts: [String: [any ContactPresentable]]
    let sortedKeys: [String]

    init(contacts: [any ContactPresentable]) {
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

    func contacts(for key: String) -> [any ContactPresentable] {
        groupedContacts[key] ?? []
    }

    static func searchName(_ contact: any ContactPresentable) -> String {
        contact.lastName ?? contact.firstName ?? contact.company ?? ""
    }
}
