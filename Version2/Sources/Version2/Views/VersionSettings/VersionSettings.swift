//
//  VersionSettings.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import SwiftData
import SwiftUI

@MainActor
struct VersionSettings: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(Coordinator.self) private var coordinator

    @State private var vm: VersionSettingsVM

    init(coordinator: Coordinator) {
        _vm = State(initialValue: .init(coordinator: coordinator))
    }

    var body: some View {
        @Bindable var vm = vm

        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    statusBlock
                    postMigrationBlock
                    actionsBlock
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                    }
                    .disabled(coordinator.repairState == .running)
                }
            }
            .interactiveDismissDisabled(coordinator.repairState == .running)
        }
    }

    private var statusBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            headingText(Constants.Settings.schemaHeader)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(Constants.Settings.version(2))
                    .font(.largeTitle.weight(.bold))

                Text(vm.versionHealth)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(healthColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(healthColor.opacity(0.15))
                    )
            }

            Text(vm.versionHealthFooter)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var postMigrationBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            headingText(Constants.Settings.postMigrationHeader)

            Text(vm.postMigrationStatus)
                .font(.title3.weight(.semibold))

            Text(vm.versionHealthFooter)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var actionsBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            headingText(Constants.Settings.actionsHeader)

            Button(action: {
                vm.hardRefresh(context: context)
            }) {
                if coordinator.repairState == .running {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(Constants.Settings.repairingInProgress)
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                } else {
                    Label(Constants.Settings.hardRefresh, systemImage: Constants.Settings.hardRefreshSymbol)
                        .font(.body.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(coordinator.repairState == .failed ? .orange : .blue)
            .disabled(coordinator.repairState == .running)

            Text(
                coordinator.repairState == .running
                    ? Constants.Settings.runningFooter
                    : Constants.Settings.hardRefreshDescription
            )
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var healthColor: Color {
        switch coordinator.repairState {
        case .idle: return .green
        case .running: return .blue
        case .failed: return .red
        }
    }

    private func headingText(_ string: String) -> some View {
        Text(string)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(1.2)
    }
}

#Preview {
    VersionSettings(coordinator: Coordinator())
        .environment(Coordinator())
        .modelContainer(PreviewSupport.container)
}
