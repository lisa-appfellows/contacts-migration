//
//  ContainerFailureView.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public struct ContainerFailureView: View {
    public let reloadAction: () -> Void

    public init(reloadAction: @escaping () -> Void) {
        self.reloadAction = reloadAction
    }

    public var body: some View {
        ContentUnavailableView {
            Label(Constants.Container.failureTitle, systemImage: "exclamationmark.triangle.fill")
        } description: {
            Text(Constants.Container.failureDescription)
        } actions: {
            Button(action: reloadAction) {
                Text(Constants.Container.reload)
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
    ContainerFailureView() {}
}
