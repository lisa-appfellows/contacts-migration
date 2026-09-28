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
        VStack(alignment: .leading, spacing: 8) {
            HeaderText(Constants.Detail.notes)
            Text(notes)
                .bold()
                .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
