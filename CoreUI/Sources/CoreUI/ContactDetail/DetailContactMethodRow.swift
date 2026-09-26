//
//  DetailContactMethodRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailContactMethodRow: View {
    private let headerText: String
    private let value: String
    private let systemIcon: String

    public init(headerText: String, value: String, systemIcon: String) {
        self.headerText = headerText
        self.value = value
        self.systemIcon = systemIcon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderText(headerText)
            HStack {
                Text(value).bold()
                Spacer()
                Image(systemName: systemIcon)
            }
        }
    }

    public static func phone(headerText: String, number: String) -> DetailContactMethodRow {
        .init(headerText: headerText, value: number, systemIcon: "phone.fill")
    }

    public static func email(_ email: String) -> DetailContactMethodRow {
        .init(headerText: "Email", value: email, systemIcon: "envelope.fill")
    }
}
