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
            TextField(Constants.Editor.firstName, text: $firstName)
            TextField(Constants.Editor.lastName, text: $lastName)
            TextField(Constants.Editor.company, text: $company)
        }
    }
}
