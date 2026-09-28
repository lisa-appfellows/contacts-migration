//
//  DetailEditToolbarButton.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct DetailEditToolbarButton: View {
    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(Constants.Detail.edit, action: action)
    }
}
