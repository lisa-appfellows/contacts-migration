//
//  DetailProfileIconRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import SwiftUI

public struct DetailProfileIconRow: View {
    private let contact: any ContactPresentable

    public init(contact: any ContactPresentable) {
        self.contact = contact
    }

    /// Fallback avatar (person) when no contact is available yet.
    public init() {
        contact = FallbackContact()
    }

    public var body: some View {
        HStack {
            Spacer()
            ContactAvatar(contact: contact, size: 180)
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}

private struct FallbackContact: ContactPresentable {
    var stableId = ""
    var firstName: String?
    var lastName: String?
    var company: String?
}
