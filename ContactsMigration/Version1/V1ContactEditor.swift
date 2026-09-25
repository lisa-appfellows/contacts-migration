//
//  V1ContactEditor.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-24.
//

import SwiftUI

struct V1ContactEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: V1ContactVM
    let didSave: (V1ContactVM) -> Void

    init(vm: V1ContactVM, didSave: @escaping (V1ContactVM) -> Void) {
        _vm = State(initialValue: vm)
        self.didSave = didSave
    }

    var body: some View {
        NavigationStack {
            List {
                EditorProfileIconRow()

                EditorNameRow(
                    firstName: $vm.firstName,
                    lastName: $vm.lastName,
                    company: $vm.company
                )

                EditorMetadataSection(
                    items: $vm.phoneNumbers,
                    itemLimit: vm.phoneLimit,
                    newItem: { "" },
                    title: "add phone number"
                ) { $newNumber in
                    TextField("phone number", text: $newNumber)
                        .keyboardType(.numberPad)
                }

                EditorMetadataSection(
                    items: $vm.emails,
                    itemLimit: vm.emailLimit,
                    newItem: { "" },
                    title: "add email"
                ) { $newEmail in
                    TextField("email", text: $newEmail)
                        .keyboardType(.numberPad)
                }

                EditorMetadataSection(
                    items: $vm.birthdays,
                    itemLimit: vm.birthdayLimit,
                    newItem: { .now },
                    title: "add birthday"
                ) { $birthday in
                    DatePicker("birthday", selection: $birthday, displayedComponents: .date)
                }

                EditorNotesSection(notes: $vm.notes)

                if !vm.isNewContact {
                    EditorDeleteContactRow(didDelete: delete)
                }
            }
            .editorViewStyle(navTitle: vm.navTitle, didSave: save) {
                dismiss()
            }
        }
    }

    private func save() {
        didSave(vm)
        dismiss()
    }

    private func delete() {
        dismiss()
    }
}

#Preview {
    V1ContactEditor(vm: .init(isNewContact: false, stableId: UUID().uuidString)) { _ in }
}
