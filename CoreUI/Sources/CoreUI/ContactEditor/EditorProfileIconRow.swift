//
//  EditorProfileIconRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import SwiftUI

public struct EditorProfileIconRow: View {
    private let contact: any ContactPresentable

    public init(contact: any ContactPresentable = ContactAvatarSource.placeholder) {
        self.contact = contact
    }

    public var body: some View {
        HStack {
            Spacer()
            ContactAvatar(contact: contact, size: 120)
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}
