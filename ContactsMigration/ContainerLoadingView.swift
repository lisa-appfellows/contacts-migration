//
//  ContainerLoadingView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-23.
//

import SwiftUI

struct LoadingContact: ContactPresentable {
    var stableId: String = ""
    var firstName: String?
    var lastName: String?
    var company: String? = "Company Name Incorporated"
}

struct ContainerLoadingView: View {
    var body: some View {
        NavigationStack {
            List(1...6, id: \.self) { _ in
                Section {
                    ContactListRow(contact: LoadingContact())
                        .shimmer()
                } header: {
                    Text("A")
                }
            }
            .redacted(reason: .placeholder)
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContainerLoadingView()
}
