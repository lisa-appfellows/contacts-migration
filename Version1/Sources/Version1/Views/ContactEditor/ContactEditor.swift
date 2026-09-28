//
//  ContactEditor.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

@MainActor
struct ContactEditor: View {
    @Environment(Router.self) private var router

    @State private var contactVM: ContactVM
    @State private var vm: ContactEditorVM
    /// Avatar frozen at open — does not follow name/company edits this session.
    private let profileSnapshot: ContactAvatarSource

    init(dto: ContactDTO?, storeRepo: StoreRepository) {
        _contactVM = State(initialValue: .init(from: dto))
        _vm = State(initialValue: .init(storeRepo: storeRepo))
        if let dto {
            profileSnapshot = .init(contact: dto)
        } else {
            profileSnapshot = .placeholder
        }
    }

    var body: some View {
        @Bindable var contactVM = contactVM
        @Bindable var vm = vm

        NavigationStack {
            List {
                if let alert = vm.editAlert {
                    Section {
                        EditorAlertBanner(editFailure: alert.editFailure) {
                            vm.tryAgain(alert)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

                EditorProfileIconRow(contact: profileSnapshot)

                EditorNameRow(
                    firstName: $contactVM.firstName,
                    lastName: $contactVM.lastName,
                    company: $contactVM.company
                )

                EditorMetadataSection(
                    items: $contactVM.phoneNumbers,
                    itemLimit: contactVM.phoneLimit,
                    newItem: { "" },
                    title: CoreUI.Constants.Editor.addPhoneNumber
                ) { $newNumber in
                    TextField(CoreUI.Constants.Editor.phoneNumberPlaceholder, text: $newNumber)
                        .keyboardType(.numberPad)
                }

                EditorMetadataSection(
                    items: $contactVM.emails,
                    itemLimit: contactVM.emailLimit,
                    newItem: { "" },
                    title: CoreUI.Constants.Editor.addEmail
                ) { $newEmail in
                    TextField(CoreUI.Constants.Editor.emailPlaceholder, text: $newEmail)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                EditorMetadataSection(
                    items: $contactVM.birthdays,
                    itemLimit: contactVM.birthdayLimit,
                    newItem: { .now },
                    title: CoreUI.Constants.Editor.addBirthday
                ) { $birthday in
                    DatePicker(CoreUI.Constants.Editor.birthday, selection: $birthday, displayedComponents: .date)
                }

                EditorNotesSection(notes: $contactVM.notes)

                if !contactVM.isNewContact {
                    EditorDeleteContactRow(didDelete: { delete() })
                }
            }
            .editorViewStyle(
                navTitle: vm.navTitle(isNewContact: contactVM.isNewContact),
                didSave: { save() },
                didDismiss: { router.dismissSheet() }
            )
            .onChange(of: vm.finishAction) { _, action in
                guard let action else { return }
                if action == .deleted {
                    router.popToRoot()
                }
                router.dismissSheet()
            }
        }
    }

    private func save() {
        vm.save(contactVM.dto, isNewContact: contactVM.isNewContact)
    }

    private func delete() {
        vm.delete(contactVM.dto)
    }
}

#Preview("New Contact") {
    ContactEditor(dto: nil, storeRepo: PreviewSupport.storeRepo)
        .environment(Router())
}

#Preview("Existing contact") {
    ContactEditor(
        dto: ContactDTO(
            firstName: "Sally",
            lastName: "Smith",
            phoneNumber: "555-222-3333"
        ),
        storeRepo: PreviewSupport.storeRepo
    )
    .environment(Router())
}
