//
//  DetailNameRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailNameRow: View {
    private let firstName: String
    private let lastName: String
    private let company: String

    @ScaledMetric(relativeTo: .largeTitle)
    private var nameSize: CGFloat = 56

    public init(firstName: String, lastName: String, company: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
    }

    public var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(firstName + " " + lastName)
                    .font(.system(size: nameSize))
                Text(company)
                    .font(.title)
            }
            .bold()
            .foregroundStyle(.white)
            .shadow(color: .blue.opacity(0.8), radius: 4)
            Spacer()
        }
        .padding(.top, 24)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}
