//
//  StoreService.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import Core
import OSLog
import SwiftData
import SwiftUI
import Version1
import Version2

enum StoreLoadingState {
    case loading
    case containerFailure
    case v1Ready(ModelContainer)
    case v2Ready(ModelContainer)
}

@Observable
final class StoreService {
    typealias ContainerFactory = (_ inMemoryOnly: Bool) throws -> ModelContainer

    /// Persisted schema version so cold start opens the same container the user last used.
    static let persistedVersionKey = "ContactsMigration.store.currentVersion"
    /// Persisted container health so V1 Settings Retry survives relaunch after a failed migrate.
    static let persistedContainerStateKey = "ContactsMigration.store.containerState"

    private let logger = AppLogger.storeService

    private let inMemoryOnly: Bool
    private let defaults: UserDefaults
    private let makeV1: ContainerFactory
    private let makeV2: ContainerFactory
    private var modelContainer: ModelContainer?

    /// Prevents overlapping migrate Tasks from racing (second failure must not
    /// stamp V1-failed over a successful V2 swap).
    private var isMigratingToV2 = false

    private(set) var versionState = VersionState()
    private(set) var loadingState = StoreLoadingState.loading

    var isVersion1: Bool {
        versionState.current == 1
    }

    init(
        inMemoryOnly: Bool = false,
        defaults: UserDefaults = .standard,
        makeV1: @escaping ContainerFactory = { try Version1.container(inMemoryOnly: $0) },
        makeV2: @escaping ContainerFactory = { try Version2.container(inMemoryOnly: $0) }
    ) {
        self.inMemoryOnly = inMemoryOnly
        self.defaults = defaults
        self.makeV1 = makeV1
        self.makeV2 = makeV2

        boot(from: Self.readPersistedVersionState(from: defaults))
    }

    func reloadContainer() {
        guard !isMigratingToV2 else { return }
        loadingState = .loading
        // Always re-read defaults so a failed V2 cold start still retries V2.
        boot(from: Self.readPersistedVersionState(from: defaults))
    }

    func migrateToV2() {
        guard isVersion1, !isMigratingToV2 else { return }

        logger.info("Swapping from V1 to V2")
        isMigratingToV2 = true
        loadingState = .loading

        // Allow ContentView to paint ContainerLoadingView before the (sync) V2
        // container build; otherwise loading → v2Ready can collapse into one frame.
        Task { @MainActor in
            defer { isMigratingToV2 = false }
            await Task.yield()

            // Bail if something else already moved us off V1 while we yielded.
            guard versionState.current == 1 else { return }

            do {
                let v2Container = try makeV2(inMemoryOnly)
                modelContainer = v2Container
                applyAndPersist(.init(current: 2, containerState: .healthy))
                loadingState = .v2Ready(v2Container)
            } catch {
                let errorDescription = error.localizedDescription
                if let modelContainer, versionState.current == 1 {
                    logger.error("V2 failed to create new container; staying at V1 container; error: \(errorDescription)")
                    applyAndPersist(.init(current: 1, containerState: .v2ContainerFailed))
                    loadingState = .v1Ready(modelContainer)
                } else if versionState.current == 1 {
                    logger.error("V2 failed to create new container, failed to unwrap V1 container; error: \(errorDescription)")
                    loadingState = .containerFailure
                } else {
                    logger.error("V2 migrate Task aborted after version already advanced; error: \(errorDescription)")
                }
            }
        }
    }

    // MARK: - Persistence

    static func readPersistedVersionState(from defaults: UserDefaults) -> VersionState {
        let stored = defaults.integer(forKey: persistedVersionKey)
        let current = stored == 2 ? 2 : 1
        // `v2ContainerFailed` only applies while still on V1 (failed migrate).
        // Ignore a corrupted combo of current=2 + failed.
        let containerState: ContainerState
        if current == 2 {
            containerState = .healthy
        } else {
            containerState = readPersistedContainerState(from: defaults)
        }
        return VersionState(current: current, containerState: containerState)
    }

    static func readPersistedVersion(from defaults: UserDefaults) -> Int {
        readPersistedVersionState(from: defaults).current
    }

    private static func readPersistedContainerState(from defaults: UserDefaults) -> ContainerState {
        let raw = defaults.string(forKey: persistedContainerStateKey)
        switch raw {
        case "v2ContainerFailed":
            return .v2ContainerFailed
        default:
            return .healthy
        }
    }

    private static func containerStateRawValue(_ state: ContainerState) -> String {
        switch state {
        case .healthy:
            return "healthy"
        case .v2ContainerFailed:
            return "v2ContainerFailed"
        }
    }

    private func applyAndPersist(_ state: VersionState) {
        persist(state)
        versionState = state
    }

    private func persist(_ state: VersionState) {
        defaults.set(state.current, forKey: Self.persistedVersionKey)
        defaults.set(Self.containerStateRawValue(state.containerState), forKey: Self.persistedContainerStateKey)
    }

    private func boot(from persisted: VersionState) {
        do {
            if persisted.current == 2 {
                let v2Container = try makeV2(inMemoryOnly)
                modelContainer = v2Container
                versionState = .init(current: 2, containerState: .healthy)
                loadingState = .v2Ready(v2Container)
            } else {
                let v1Container = try makeV1(inMemoryOnly)
                modelContainer = v1Container
                versionState = .init(current: 1, containerState: persisted.containerState)
                loadingState = .v1Ready(v1Container)
            }
        } catch {
            logger.error(
                "Failed to create version \(persisted.current) model container; error: \(error.localizedDescription)"
            )
            // Keep in-memory current aligned with what we attempted so diagnostics
            // match defaults; Reload re-reads defaults and retries the same factory.
            versionState = .init(current: persisted.current, containerState: persisted.containerState)
            loadingState = .containerFailure
        }
    }
}
