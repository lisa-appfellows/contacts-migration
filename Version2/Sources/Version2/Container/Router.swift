//
//  Router.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

@MainActor
@Observable
final class Router {
    var path = NavigationPath()
    var sheet: Sheet?

    func presentEditor(stableId: String? = nil) {
        sheet = .editor(stableId: stableId)
    }

    func presentVersionSettings() {
        sheet = .versionSettings
    }

    func dismissSheet() {
        sheet = nil
    }

    func popToRoot() {
        path = NavigationPath()
    }
}

enum Sheet: Identifiable {
    case editor(stableId: String? = nil)
    case versionSettings

    var id: String {
        switch self {
        case .editor(let stableId):
            return "editor_\(stableId ?? "new")"
        case .versionSettings:
            return "version_settings"
        }
    }
}
