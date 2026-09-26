//
//  EditorNotesSection.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorNotesSection: View {
    @Binding private var notes: String

    public init(notes: Binding<String>) {
        _notes = notes
    }

    public var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text("Notes")
                TextEditor(text: $notes)
            }
            .frame(height: 180)
        }
    }
}
