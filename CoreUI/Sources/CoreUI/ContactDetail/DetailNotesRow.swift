//
//  DetailNotesRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailNotesRow: View {
    private let notes: String

    public init(notes: String) {
        self.notes = notes
    }

    public var body: some View {
        VStack {
            HeaderText("Notes")
            Text(notes)
                .bold()
                .frame(height: 180)
        }
    }
}
