//
//  StoreServiceTests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

final class StoreServiceTests: XCTestCase {
    @MainActor
    func testInit_setsV1Ready() {
        let service = StoreService(inMemoryOnly: true)

        XCTAssertTrue(service.isVersion1)
        XCTAssertTrue(service.canMigrate)
        guard case .v1Ready(let container, let event) = service.loadingState else {
            return XCTFail("Expected v1Ready, got \(service.loadingState)")
        }
        XCTAssertEqual(event, .none)
        XCTAssertNotNil(container)
    }

    @MainActor
    func testMigrateToV2_reachesV2Ready() async throws {
        let service = StoreService(inMemoryOnly: true)
        service.migrateToV2()

        try await waitForLoadingState(on: service) { state in
            if case .v2Ready = state { return true }
            if case .v2NeedsRepair = state {
                XCTFail("Post-migration failed unexpectedly")
                return true
            }
            return false
        }

        XCTAssertFalse(service.isVersion1)
        XCTAssertFalse(service.canMigrate)
        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected v2Ready, got \(service.loadingState)")
        }
    }

    @MainActor
    func testRefreshRepairs_fromV2Ready_staysReady() async throws {
        let service = StoreService(inMemoryOnly: true)
        service.migrateToV2()
        try await waitForLoadingState(on: service) {
            if case .v2Ready = $0 { return true }
            return false
        }

        service.refreshRepairs()

        try await waitForLoadingState(on: service) { state in
            if case .v2Migrating = state { return false }
            if case .v2Ready = state { return true }
            if case .v2NeedsRepair = state {
                XCTFail("Refresh unexpectedly needs repair")
                return true
            }
            return false
        }

        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected v2Ready after refresh, got \(service.loadingState)")
        }
    }

    @MainActor
    func testRefreshRepairs_onV1_isNoOp() {
        let service = StoreService(inMemoryOnly: true)
        service.refreshRepairs()

        guard case .v1Ready(_, let event) = service.loadingState else {
            return XCTFail("Expected v1Ready, got \(service.loadingState)")
        }
        XCTAssertEqual(event, .none)
        XCTAssertTrue(service.isVersion1)
    }

    @MainActor
    private func waitForLoadingState(
        on service: StoreService,
        timeoutSeconds: TimeInterval = 5,
        matches: (StoreLoadingState) -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        while Date() < deadline {
            if matches(service.loadingState) { return }
            try await Task.sleep(nanoseconds: 50_000_000)
        }
        XCTFail("Timed out waiting for loading state, last state: \(service.loadingState)")
    }
}
