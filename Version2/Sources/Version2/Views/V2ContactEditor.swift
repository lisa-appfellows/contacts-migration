//
//  V2ContactEditor.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

struct V2ContactEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var vm: V2ContactVM
    let didSave: (V2ContactVM) -> Void

    init(vm: V2ContactVM, didSave: @escaping (V2ContactVM) -> Void) {
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
                    newItem: { .init(tag: .mobile, number: "") },
                    title: "add phone number"
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
                        
                        TextField("Phone", text: $newNumber.number)
                    }
                    .fixedSize(horizontal: false, vertical: true)
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
    V2ContactEditor(vm: .init(
        isNewContact: false,
        stableId: UUID().uuidString,
        repairVersion: 2
    )) { _ in }
}

