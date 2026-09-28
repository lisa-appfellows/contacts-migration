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

    private var personName: String {
        let parts = [firstName, lastName].filter { !$0.isEmpty }
        return parts.joined(separator: " ")
    }

    private var hasPersonName: Bool { !personName.isEmpty }
    private var hasCompany: Bool { !company.isEmpty }

    public var body: some View {
        VStack(spacing: 4) {
            if hasPersonName {
                Text(personName)
                    .font(.system(size: nameSize))
                if hasCompany {
                    Text(company)
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
            } else if hasCompany {
                Text(company)
                    .font(.system(size: nameSize))
            } else {
                Text(Constants.Detail.noName)
                    .font(.system(size: nameSize))
                    .foregroundStyle(.secondary)
            }
        }
        .bold()
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}
