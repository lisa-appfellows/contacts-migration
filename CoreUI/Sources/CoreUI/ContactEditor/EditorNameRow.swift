//
//  EditorNameRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorNameRow: View {
    @Binding private var firstName: String
    @Binding private var lastName: String
    @Binding private var company: String

    public init(
        firstName: Binding<String>,
        lastName: Binding<String>,
        company: Binding<String>
    ) {
        _firstName = firstName
        _lastName = lastName
        _company = company
    }

    public var body: some View {
        Section {
            TextField("First Name", text: $firstName)
            TextField("Last Name", text: $lastName)
            TextField("Company", text: $company)
        }
    }
}
