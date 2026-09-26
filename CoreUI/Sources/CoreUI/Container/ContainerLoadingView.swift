//
//  ContainerLoadingView.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import SwiftUI

struct LoadingContact: ContactPresentable {
    var stableId: String = ""
    var firstName: String?
    var lastName: String?
    var company: String? = "Company Name Incorporated"
}

public struct ContainerLoadingView: View {
    public init() {}
    public var body: some View {
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
