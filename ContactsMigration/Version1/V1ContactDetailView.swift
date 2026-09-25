//
//  V1ContactDetailView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-24.
//

import SwiftUI

struct V1ContactDetailView: View, Hashable {
    @Binding var sheet: V1Sheet?
    let vm: V1ContactVM
    
    var body: some View {
        List {
            DetailProfileIconRow()
            DetailNameRow(
                firstName: vm.firstName,
                lastName: vm.lastName,
                company: vm.company
            )

            Section {
                Group {
                    if let phoneNumber = vm.phoneNumbers.first {
                        DetailContactMethodRow.phone(
                            headerText: "Phone number",
                            number: phoneNumber
                        )
                    }

                    if let email = vm.emails.first {
                        DetailContactMethodRow.email(email)
                    }

                    DetailNotesRow(notes: vm.notes)
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.blue.opacity(0.2))
            }
        }
        .detailViewStyle { sheet = .editor(vm) }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(vm.stableId)
    }

    static func == (lhs: V1ContactDetailView, rhs: V1ContactDetailView) -> Bool {
        lhs.vm.stableId == rhs.vm.stableId
    }
}

#Preview {
    NavigationStack {
        V1ContactDetailView(
            sheet: .constant(nil),
            vm: .init(
                stableId: UUID().uuidString,
                firstName: "Sally",
                lastName: "Smith",
                company: "XYZ Company",
                phoneNumbers: ["555-222-3333"],
                emails: ["sally.smith@mail.com"]
            )
        )
    }
}
