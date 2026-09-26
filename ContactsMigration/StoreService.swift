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
    case v1Ready(ModelContainer, event: Version1.StoreEvent)
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
            let v1Container = try Version1.container(inMemoryOnly: inMemoryOnly)
            self.modelContainer = v1Container
            loadingState = .v1Ready(v1Container, event: .none)
        } catch {
            logger.error("Failed to create V1 model container; error: \(error.localizedDescription)")
            loadingState = .containerFailure
        }
    }

    func migrateToV2() {
        guard canMigrate else { return }

        logger.info("Swapping from V1 to V2")
        loadingState = .loading

        do {
            let v2Container = try Version2.container(inMemoryOnly: inMemoryOnly)
            modelContainer = v2Container
            isVersion1 = false
            runPostMigration(v2Container)
        } catch {
            let errorDescription = error.localizedDescription
            if let modelContainer {
                logger.error("V2 failed to create new container; staying at V1 container; error: \(errorDescription)")
                loadingState = .v1Ready(modelContainer, event: Version1.StoreEvent.v2ContainerFailed)
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
                    try await Version2.postMigration(container: container).runIfNeeded()
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
