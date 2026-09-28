//
//  VersionSettings.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import CoreUI
import SwiftUI

@MainActor
struct VersionSettings: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.versionState) private var versionState

    @State private var vm: VersionSettingsVM
    let migrateTapped: () -> Void

    init(
        storeRepo: StoreRepository,
        isStoreEmpty: Bool,
        migrateTapped: @escaping () -> Void
    ) {
        _vm = State(initialValue: .init(
            storeRepo: storeRepo,
            isStoreEmpty: isStoreEmpty
        ))
        self.migrateTapped = migrateTapped
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    statusBlock
                    seedBlock
                    migrateBlock
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
                    .disabled(vm.isMigrating)
                }
            }
            .onAppear { vm.applyVersionState(versionState) }
            .onChange(of: versionState) { _, newValue in
                vm.applyVersionState(newValue)
            }
            .interactiveDismissDisabled(vm.isMigrating)
        }
    }

    private var statusBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            headingText(Constants.Settings.schemaHeader)

            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text(Constants.Settings.version(vm.versionState.current))
                    .font(.largeTitle.weight(.bold))

                Text(vm.versionHealth)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(vm.versionIsHealthy ? Color.green : Color.red)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill((vm.versionIsHealthy ? Color.green : Color.red).opacity(0.15))
                    )
            }

            Text(vm.versionHealthFooter)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var seedBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            headingText(Constants.Settings.sampleDataHeader)

            if vm.isStoreEmpty {
                Button(action: { vm.seed() }) {
                    settingsButtonLabel(text: Constants.Settings.seedContacts, icon: "leaf.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(.blue)

                footerText(vm.seedFooter)
            } else {
                Label(Constants.Settings.contactsSeeded, systemImage: "checkmark.circle.fill")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var migrateBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            headingText(Constants.Settings.upgradeHeader)

            Button(action: startMigrate) {
                if vm.isMigrating {
                    HStack(spacing: 10) {
                        ProgressView()
                        Text(Constants.Settings.migratingDescription)
                            .font(.body.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                } else {
                    settingsButtonLabel(text: vm.migrateTitle, icon: vm.migrateSymbol)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(vm.versionIsHealthy ? .blue : .orange)
            .disabled(vm.isMigrating)

            footerText(vm.migrateFooter)
        }
    }

    private func startMigrate() {
        guard !vm.isMigrating else { return }
        vm.beginMigrate()
        // Let the migrating chrome paint before StoreService creates the V2 container.
        Task { @MainActor in
            await Task.yield()
            migrateTapped()
        }
    }

    private func headingText(_ string: String) -> some View {
        Text(string)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
            .tracking(1.2)
    }

    private func settingsButtonLabel(text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .font(.body.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
    }

    private func footerText(_ string: String) -> some View {
        Text(string)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview("Healthy Version") {
    VersionSettings(
        storeRepo: PreviewSupport.storeRepo,
        isStoreEmpty: true,
        migrateTapped: {}
    )
    .environment(\.versionState, .init())
}

#Preview("Failed Version") {
    VersionSettings(
        storeRepo: PreviewSupport.storeRepo,
        isStoreEmpty: false,
        migrateTapped: {}
    )
    .environment(\.versionState, .init(containerState: .v2ContainerFailed))
}
