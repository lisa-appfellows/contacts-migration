//
//  StoreService.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import OSLog
import SwiftData
import SwiftUI

enum StoreEvent: Equatable { case none, v2ContainerFailed }

enum StoreLoadingState {
    case loading
    case containerFailure
    case v1Ready(ModelContainer, event: StoreEvent)
    case v2Migrating(ModelContainer)
    case v2Ready(ModelContainer)
    case v2NeedsRepair(ModelContainer)
}

@Observable
final class StoreService {
    private let logger = AppLogger.storeService

    private let inMemoryOnly: Bool
    private var modelContainer: ModelContainer?

    private(set) var isVersion1 = true
    private(set) var loadingState = StoreLoadingState.loading

    var canMigrate: Bool { isVersion1 }

    init(inMemoryOnly: Bool = false) {
        self.inMemoryOnly = inMemoryOnly

        do {
            let v1Container = try Self.containerV1(inMemoryOnly: inMemoryOnly)
            self.modelContainer = v1Container
            loadingState = .v1Ready(v1Container, event: .none)
        } catch {
            logger.error("Failed to create V1 model container; error: \(error.localizedDescription)")
            loadingState = .containerFailure
        }
    }

    @MainActor 
    func storeRepoV1(_ context: ModelContext) -> StoreRepositoryV1 {
        .init(context: context)
    }

    @MainActor
    func storeRepoV2(_ context: ModelContext) -> StoreRepositoryV2 {
        .init(context: context)
    }

    func migrateToV2() {
        guard canMigrate else { return }

        logger.info("Swapping from V1 to V2")
        loadingState = .loading

        do {
            let v2Container = try Self.containerV2(inMemoryOnly: inMemoryOnly)
            modelContainer = v2Container
            isVersion1 = false
            runPostMigration(v2Container)
        } catch {
            let errorDescription = error.localizedDescription
            if let modelContainer {
                logger.error("V2 failed to create new container; staying at V1 container; error: \(errorDescription)")
                loadingState = .v1Ready(modelContainer, event: .v2ContainerFailed)
            } else {
                logger.error("V2 failed to create new container, failed to unwrap V1 container; error: \(errorDescription)")
                loadingState = .containerFailure
            }
        }
    }

    func refreshRepairs() {
        guard let modelContainer else {
            loadingState = .containerFailure
            logger.error("Failed to unwrap v2ModelContainer for refreshing repairs")
            return
        }

        runPostMigration(modelContainer)
    }

    private func runPostMigration(_ container: ModelContainer) {
        guard !isVersion1 else { return }
        loadingState = .v2Migrating(container)

        Task {
            var attempts = 0
            while attempts < 3 {
                do {
                    try await PostMigration(modelContainer: container).runIfNeeded()
                    logger.info("V2 post-migration complete after \(attempts) attempts")
                    loadingState = .v2Ready(container)
                    return
                } catch {
                    logger.error("V2 post-migration failed on \(attempts) attempt; error: \(error.localizedDescription)")
                    attempts += 1
                }
            }
            
            logger.error("Post-migration failed after 3 attempts")
            loadingState = .v2NeedsRepair(container)
        }
    }
}

extension StoreService {
    static func containerV1(inMemoryOnly: Bool) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV1.self),
            migrationPlan: MigrationPlanV1.self,
            configurations: .init(isStoredInMemoryOnly: inMemoryOnly)
        )
    }

    static func containerV2(inMemoryOnly: Bool) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: SchemaV2.self),
            migrationPlan: MigrationPlanV2.self,
            configurations: .init(isStoredInMemoryOnly: inMemoryOnly)
        )
    }
}
