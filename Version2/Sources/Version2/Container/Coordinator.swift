//
//  Coordinator.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Core
import Foundation
import SwiftData

enum RepairState: Equatable { case idle, running, failed }

@MainActor
@Observable
final class Coordinator {
    private let logger = AppLogger.postMigration
    private let runPostMigration: @MainActor (ModelContext) async throws -> Void

    var repairState = RepairState.idle

    init(
        runPostMigration: @escaping @MainActor (ModelContext) async throws -> Void = { context in
            try PostMigration.runIfNeeded(context: context)
        }
    ) {
        self.runPostMigration = runPostMigration
    }

    func refreshRepairs(context: ModelContext) {
        guard repairState != .running else { return }
        repairState = .running

        Task { @MainActor in
            // Let the loading UI paint before doing store work on the main context.
            await Task.yield()

            var attempts = 0
            while attempts < 3 {
                do {
                    try await runPostMigration(context)
                    logger.info("V2 post-migration complete after \(attempts + 1) attempt(s)")
                    repairState = .idle
                    return
                } catch {
                    logger.error(
                        "V2 post-migration failed on attempt \(attempts + 1); error: \(error.localizedDescription)"
                    )
                    attempts += 1
                }
            }

            logger.error("Post-migration failed after 3 attempts")
            repairState = .failed
        }
    }
}
