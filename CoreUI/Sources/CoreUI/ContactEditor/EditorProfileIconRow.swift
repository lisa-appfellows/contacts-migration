//
//  EditorProfileIconRow.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct EditorProfileIconRow: View {
    public init() {}
    public var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .frame(width: 120, height: 120)
                .background(
                    Circle().fill(.blue.gradient)
                )
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}
