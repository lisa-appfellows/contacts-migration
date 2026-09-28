//
//  ContactListView.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct ContactListView: View {
    public let model: ContactListModel
    public let versionTapped: () -> Void
    public let newContactTapped: () -> Void

    public init(
        model: ContactListModel,
        versionTapped: @escaping () -> Void,
        newContactTapped: @escaping () -> Void
    ) {
        self.model = model
        self.versionTapped = versionTapped
        self.newContactTapped = newContactTapped
    }

    public var body: some View {
        Group {
            if model.sortedKeys.isEmpty {
                ContentUnavailableView {
                    Label(Constants.List.emptyTitle, systemImage: "person.crop.circle.badge.plus")
                } description: {
                    Text(Constants.List.emptyDescription)
                } actions: {
                    Button(Constants.List.addContact, action: newContactTapped)
                }
            } else {
                List {
                    ForEach(model.sortedKeys, id: \.self) { key in
                        Section {
                            ForEach(model.contacts(for: key), id: \.stableId) { contact in
                                ContactListRow(contact: contact)
                            }
                        } header: {
                            Text(key)
                        }
                    }
                }
            }
        }
        .navigationTitle(Constants.List.navigationTitle)
        .toolbarBackground(Material.ultraThin, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: versionTapped) {
                    Text(Constants.List.version(model.version))
                        .font(.caption.bold())
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: newContactTapped) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    ContactListView(model: .mock(version: 1)) {
        print("Version tapped")
    } newContactTapped: {
        print("New Contact tapped")
    }

}
