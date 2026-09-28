//
//  RepairFailureBanner.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import CoreUI
import SwiftUI

struct RepairFailureBanner: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
                .font(.body)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)

            Button(Constants.Repair.tryAgain, action: retryAction)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.small)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.12))
    }
}

#Preview {
    RepairFailureBanner(message: Constants.Repair.containerFailureMessage) {}
}
