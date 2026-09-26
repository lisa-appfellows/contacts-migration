//
//  V2Router.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import CoreUI
import SwiftUI

@Observable
final class V2Router {
    var path = NavigationPath()
    var sheet: V2Sheet?
    var contactDict = [String: V2Contact]()

    var boundSheet: Binding<V2Sheet?> {
        Binding<V2Sheet?>(
            get: { self.sheet },
            set: { newSheet in self.sheet = newSheet }
        )
    }

    func createDictionary(from contacts: [V2Contact]) {
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
        let vm = V2ContactVM(from: model)
        sheet = .editor(vm)
    }

    @ViewBuilder
    func detailView(for stableId: String) -> some View {
        if let model = contactDict[stableId] {
            let vm = V2ContactVM(from: model)
            V2ContactDetailView(sheet: boundSheet, vm: vm)
        } else {
            ContactUnavailableView {
                self.path.removeLast()
                self.path.append(stableId)
            }
        }
    }
}

enum V2Sheet: Identifiable {
    case editor(V2ContactVM = .init())

    var id: String {
        switch self {
        case .editor(let vm):
            return vm.stableId
        }
    }

    func view(didSave: @escaping (V2ContactVM) -> Void) -> some View {
        switch self {
        case .editor(let vm):
            V2ContactEditor(vm: vm, didSave: didSave)
        }
    }
}

