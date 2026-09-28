//
//  ContactDetailView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftData
import SwiftUI

@MainActor
struct ContactDetailView: View {
    @Environment(\.modelContext) private var context
    @Environment(Coordinator.self) private var coordinator

    let dto: ContactDTO
    private let editTapped: () -> Void

    init(dto: ContactDTO, editTapped: @escaping () -> Void) {
        self.dto = dto
        self.editTapped = editTapped
    }

    private var canEdit: Bool { !dto.isBehindOnRepair }

    var body: some View {
        List {
            repairBannerSection

            DetailProfileIconRow(contact: dto)

            DetailNameRow(
                firstName: dto.firstName ?? "",
                lastName: dto.lastName ?? "",
                company: dto.company ?? ""
            )

            if !dto.phoneNumbers.isEmpty
                || dto.displayLegacyPhoneNumber != nil
                || dto.email != nil
                || dto.birthday != nil
                || !(dto.notes ?? "").isEmpty
            {
                Section {
                    ForEach(dto.phoneNumbers, id: \.id) { phone in
                        DetailContactMethodRow.phone(
                            headerText: phone.tag.rawValue,
                            number: phone.number
                        )
                    }

                    // Display-only — never merged into dto.phoneNumbers / save path.
                    if let legacy = dto.displayLegacyPhoneNumber {
                        DetailContactMethodRow.phone(
                            headerText: PhoneNumberTag.mobile.rawValue,
                            number: legacy
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
        .detailViewStyle(editAction: canEdit ? editTapped : nil)
    }

    /// Detail never writes repairs itself — Try Again is store-wide via Coordinator,
    /// so we don't race a second writer and double-insert phones.
    @ViewBuilder
    private var repairBannerSection: some View {
        if dto.isBehindOnRepair {
            Section {
                switch coordinator.repairState {
                case .running:
                    HStack(spacing: 10) {
                        ProgressView()
                            .controlSize(.small)
                        Text(Constants.Repair.repairing)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.clear)

                case .failed:
                    RepairFailureBanner(message: Constants.Repair.contactFailureMessage) {
                        coordinator.refreshRepairs(context: context)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)

                case .idle:
                    RepairFailureBanner(message: Constants.Repair.editBlockedMessage) {
                        coordinator.refreshRepairs(context: context)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
        }
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
                email: "sally.smith@mail.com",
                birthday: .now,
                notes: "Met at WWDC",
                phoneNumbers: [.init(tag: .mobile, number: "555-222-3333", isPrimary: true)]
            ),
            editTapped: {}
        )
        .environment(Coordinator())
    }
}
