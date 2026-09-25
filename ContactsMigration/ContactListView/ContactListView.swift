//
//  ContactListView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import SwiftData
import SwiftUI

struct ContactListView: View {
    @Environment(StoreService.self) private var storeService
    let model: ContactListModel
    let newContactTapped: () -> Void

    var body: some View {
        Group {
            if model.sortedKeys.isEmpty {
                ContentUnavailableView {
                    Label("No Contacts", systemImage: "person.crop.circle.badge.plus")
                } description: {
                    Text("Add a contact to get started.")
                } actions: {
                    Button("Add Contact", action: newContactTapped)
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
        .navigationTitle("Contacts")
        .toolbarBackground(Material.ultraThin, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {}) {
                    Text("Version \(storeService.isVersion1 ? 1 : 2)")
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
    NavigationStack {
        ContactListView(model: .init(contacts: MockContacts.contacts)) {
            
        }
        .environment(StoreService())
    }
}
