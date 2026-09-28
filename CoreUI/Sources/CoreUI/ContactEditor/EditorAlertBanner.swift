//
//  EditorAlertBanner.swift
//  
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Core
import SwiftUI

public struct EditorAlertBanner: View {
    private let editFailure: EditFailure
    private let retryAction: () -> Void

    public init(editFailure: EditFailure, retryAction: @escaping () -> Void) {
        self.editFailure = editFailure
        self.retryAction = retryAction
    }

    public var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.body)

            Text(editFailure.message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button(Constants.Editor.tryAgain, action: retryAction)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.12))
    }
}

#Preview("Save") {
    EditorAlertBanner(editFailure: .save) {}
}

#Preview("Delete") {
    EditorAlertBanner(editFailure: .delete) {}
}
