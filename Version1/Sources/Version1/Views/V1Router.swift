//
//  V1Router.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

@Observable
final class V1Router {
    var path = NavigationPath()
    var sheet: V1Sheet?
    var contactDict = [String: V1Contact]()

    var boundSheet: Binding<V1Sheet?> {
        Binding<V1Sheet?>(
            get: { self.sheet },
            set: { newSheet in self.sheet = newSheet }
        )
    }

    func createDictionary(from contacts: [V1Contact]) {
        let newDictionary = Dictionary(
            contacts.map { ($0.stableId, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        contactDict = newDictionary
    }

    func presentEditor(stableId: String? = nil) {
        guard let stableId else {
            sheet = .editor()
            return
        }

        guard let model = contactDict[stableId] else { return }
        let vm = V1ContactVM(from: model)
        sheet = .editor(vm)
    }

    @ViewBuilder
    func detailView(for stableId: String) -> some View {
        if let model = contactDict[stableId] {
            let vm = V1ContactVM(from: model)
            V1ContactDetailView(sheet: boundSheet, vm: vm)
        } else {
            ContactUnavailableView {
                self.path.removeLast()
                self.path.append(stableId)
            }
        }
    }
}

enum V1Sheet: Identifiable {
    case editor(V1ContactVM = .init())

    var id: String {
        switch self {
        case .editor(let vm):
            return vm.stableId
        }
    }

    func view(didSave: @escaping (V1ContactVM) -> Void) -> some View {
        switch self {
        case .editor(let vm):
            V1ContactEditor(vm: vm, didSave: didSave)
        }
    }
}

