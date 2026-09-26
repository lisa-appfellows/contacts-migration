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

    private var firstInitial: String? { model.firstInitial }
    private var lastInitial: String? { model.lastInitial }

    public init(contact: any ContactPresentable) {
        model = .init(contact: contact)
    }

    public var body: some View {
        HStack(spacing: 16) {
            iconView
            Text(model.presentationName).bold()
        }
        .contentShape(Rectangle())
        .background(
            NavigationLink(value: model.contact.stableId) { EmptyView() }
                .opacity(0)
        )
    }

    @ViewBuilder
    private var iconView: some View {
        if model.isBusiness {
            Image(systemName: "building.2.fill")
                .frame(width: 44, height: 44)
                .foregroundStyle(.white)
                .background(RoundedRectangle(cornerRadius: 8).fill(.blue.gradient))
        } else {
            Group {
                if let firstInitial, let lastInitial {
                    Text(firstInitial+lastInitial)
                } else if let firstInitial {
                    Text(firstInitial)
                } else if let lastInitial {
                    Text(lastInitial)
                } else {
                    Image(systemName: "person.fill")
                }
            }
            .bold()
            .frame(width: 44, height: 44)
            .foregroundStyle(.white)
            .background(Circle().fill(.blue.gradient))
        }
    }
}

#Preview {
    ContactListRow(contact: MockContact.contacts[0])
}
