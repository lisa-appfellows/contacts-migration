//
//  DetailProfileIconRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailProfileIconRow: View {
    public init() {}
    public var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .font(.system(size: 120))
                .foregroundStyle(.white.shadow(.inner(color: .blue, radius: 1, x: -1, y: -1)))
                .frame(width: 180, height: 180)
                .background(
                    Circle()
                        .fill(.blue.gradient.opacity(0.05))
                        .strokeBorder(LinearGradient.stroke, lineWidth: 2)
                )
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}

