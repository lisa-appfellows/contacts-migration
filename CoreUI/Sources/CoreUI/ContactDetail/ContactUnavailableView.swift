//
//  ContactUnavailableView.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct ContactUnavailableView: View {
    private let reloadAction: () -> Void

    public init(reloadAction: @escaping () -> Void) {
        self.reloadAction = reloadAction
    }

    public var body: some View {
        ContentUnavailableView {
            Label(Constants.Detail.unavailableTitle, systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(Constants.Detail.unavailableDescription)
        } actions: {
            Button(action: reloadAction) {
                Text(Constants.Detail.reload)
                    .font(.system(.title3, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 48)
                    .padding(.vertical)
                    .background(Capsule())
            }
        }
    }
}

#Preview {
    ContactUnavailableView {

    }
}
