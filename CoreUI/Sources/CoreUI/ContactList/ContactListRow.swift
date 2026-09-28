//
//  ContactListRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import SwiftUI

public struct ContactListRow: View {
    private let model: ContactPresentationModel

    public init(contact: any ContactPresentable) {
        model = .init(contact: contact)
    }

    public var body: some View {
        HStack(spacing: 16) {
            ContactAvatar(model: model, size: 44)
            Text(model.presentationName).bold()
        }
        .contentShape(Rectangle())
        .background(
            NavigationLink(value: model.contact.stableId) { EmptyView() }
                .opacity(0)
        )
    }
}

#Preview {
    ContactListRow(contact: MockContact.contacts[0])
}
