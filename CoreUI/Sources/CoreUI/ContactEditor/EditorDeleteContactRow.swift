//
//  EditorDeleteContactRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorDeleteContactRow: View {
    private let didDelete: () -> Void

    public init(didDelete: @escaping () -> Void) {
        self.didDelete = didDelete
    }

    public var body: some View {
        Button(role: .destructive, action: didDelete) {
            Text("Delete Contact")
        }
    }
}
