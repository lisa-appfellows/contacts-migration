//
//  ContactDetailView.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

@MainActor
struct ContactDetailView: View {
    let dto: ContactDTO
    private let editTapped: () -> Void

    init(dto: ContactDTO, editTapped: @escaping () -> Void) {
        self.dto = dto
        self.editTapped = editTapped
    }

    var body: some View {
        List {
            DetailProfileIconRow(contact: dto)

            DetailNameRow(
                firstName: dto.firstName ?? "",
                lastName: dto.lastName ?? "",
                company: dto.company ?? ""
            )

            if dto.phoneNumber != nil
                || dto.email != nil
                || dto.birthday != nil
                || !(dto.notes ?? "").isEmpty
            {
                Section {
                    if let phoneNumber = dto.phoneNumber {
                        DetailContactMethodRow.phone(
                            headerText: CoreUI.Constants.Detail.phoneNumber,
                            number: phoneNumber
                        )
                    }

                    if let email = dto.email {
                        DetailContactMethodRow.email(email)
                    }

                    if let birthday = dto.birthday {
                        DetailContactMethodRow.birthday(birthday)
                    }

                    if let notes = dto.notes, !notes.isEmpty {
                        DetailNotesRow(notes: notes)
                    }
                }
            }
        }
        .detailViewStyle(editAction: editTapped)
    }
}

#Preview {
    NavigationStack {
        ContactDetailView(
            dto: .init(
                stableId: UUID().uuidString,
                firstName: "Sally",
                lastName: "Smith",
                company: "XYZ Company",
                phoneNumber: "555-222-3333",
                email: "sally.smith@mail.com",
                birthday: .now,
                notes: "Met at WWDC"
            ),
            editTapped: {}
        )
    }
}
