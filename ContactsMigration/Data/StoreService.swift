//
//  StoreService.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-21.
//

import SwiftData
import SwiftUI

@Observable
final class StoreService {
    private let inMemoryOnly: Bool
    private(set) var modelContainer: ModelContainer

    private(set) var isVersion1 = true
    private(set) var isLoading = true

    var canMigrate: Bool { isVersion1 }

    init(inMemoryOnly: Bool = false) {
        self.inMemoryOnly = inMemoryOnly
        self.modelContainer = Self.container(isVersion1: true, inMemoryOnly: inMemoryOnly)
        isLoading = false
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
        isLoading = true
        modelContainer = Self.container(isVersion1: false, inMemoryOnly: inMemoryOnly)
        isVersion1 = false
        Task {
            await runPostMigration()
            isLoading = false
        }
    }

    private func runPostMigration() async {
        guard !isVersion1 else { return }
        await PostMigration(modelContainer: modelContainer).runIfNeeded()
    }
}

extension StoreService {
    static func container(isVersion1: Bool, inMemoryOnly: Bool) -> ModelContainer {
        do {
            return isVersion1 ?
            try containerV1(inMemoryOnly: inMemoryOnly) :
            try containerV2(inMemoryOnly: inMemoryOnly)
        } catch {
            fatalError("Failed to create container for edition: \(isVersion1 ? 1 : 2)")
        }
    }

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
