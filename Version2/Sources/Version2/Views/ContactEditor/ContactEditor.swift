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
                if !contactVM.canEdit && !contactVM.isNewContact {
                    Section {
                        RepairFailureBanner(message: Constants.Repair.editBlockedMessage) {
                            router.dismissSheet()
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }

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

                Group {
                    EditorNameRow(
                        firstName: $contactVM.firstName,
                        lastName: $contactVM.lastName,
                        company: $contactVM.company
                    )

                    EditorMetadataSection(
                        items: $contactVM.phoneNumbers,
                        itemLimit: contactVM.phoneLimit,
                        newItem: { .init(tag: .mobile, number: "") },
                        title: CoreUI.Constants.Editor.addPhoneNumber
                    ) { $newNumber in
                        HStack {
                            Menu {
                                ForEach(PhoneNumberTag.allCases, id: \.self) { tag in
                                    let isSelected = tag == newNumber.tag
                                    Button {
                                        newNumber.tag = tag
                                    } label: {
                                        HStack {
                                            Text(tag.rawValue)
                                            if isSelected {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text(newNumber.tag.rawValue)
                            }

                            Divider()

                            TextField(CoreUI.Constants.Editor.phonePlaceholder, text: $newNumber.number)
                        }
                        .fixedSize(horizontal: false, vertical: true)
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

                    if !contactVM.isNewContact && contactVM.canEdit {
                        EditorDeleteContactRow(didDelete: { delete() })
                    }
                }
                .disabled(!contactVM.isNewContact && !contactVM.canEdit)
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
        guard contactVM.isNewContact || contactVM.canEdit else { return }
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
            phoneNumbers: [.init(tag: .mobile, number: "555-222-3333", isPrimary: true)]
        ),
        storeRepo: PreviewSupport.storeRepo
    )
    .environment(Router())
}

