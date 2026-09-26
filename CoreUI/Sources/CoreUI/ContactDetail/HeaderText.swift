//
//  HeaderText.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct HeaderText: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .textCase(.uppercase)
            .font(.caption2.bold())
    }
}
