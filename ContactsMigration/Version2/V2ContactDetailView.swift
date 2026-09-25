//
//  V2ContactDetailView.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-24.
//

import SwiftUI

struct V2ContactDetailView: View, Hashable {
    @Binding var sheet: V2Sheet?
    let vm: V2ContactVM
    
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
                    ForEach(vm.phoneNumbers, id: \.self) { model in
                        DetailContactMethodRow.phone(
                            headerText: model.tag.rawValue,
                            number: model.number
                        )
                    }

                    if let email = vm.emails.first {
                        DetailContactMethodRow.email(email)
                    }

                    DetailNotesRow(notes: vm.notes)
                }
                .foregroundStyle(.white)
                .listRowBackground(Color.blue.opacity(0.5))
            }
        }
        .detailViewStyle { sheet = .editor(vm) }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(vm.stableId)
    }

    static func == (lhs: V2ContactDetailView, rhs: V2ContactDetailView) -> Bool {
        lhs.vm.stableId == rhs.vm.stableId
    }
}

#Preview {
    NavigationStack {
        V2ContactDetailView(
            sheet: .constant(nil),
            vm: .init(
                stableId: UUID().uuidString,
                repairVersion: 2,
                firstName: "Sally",
                lastName: "Smith",
                company: "XYZ Company",
                phoneNumbers: [.init(tag: .mobile, number: "555-222-3333")],
                emails: ["sally.smith@mail.com"]
            )
        )
    }
}
