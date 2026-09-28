//
//  StoreServiceTests.swift
//  ContactsMigrationTests
//

import Core
import SwiftData
import XCTest
@testable import ContactsMigration

private enum TestContainerError: Error {
    case forcedFailure
}

@MainActor
final class StoreServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var defaultsSuiteName: String!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "StoreServiceTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        defaults = nil
        defaultsSuiteName = nil
        super.tearDown()
    }

    func testInit_setsV1ReadyHealthy() {
        let service = makeService()

        XCTAssertTrue(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 1)
        XCTAssertEqual(service.versionState.containerState, .healthy)
        guard case .v1Ready = service.loadingState else {
            return XCTFail("Expected v1Ready, got \(service.loadingState)")
        }
    }

    func testInit_whenPersistedVersionIs2_bootsV2() {
        persist(.init(current: 2, containerState: .healthy))

        let service = makeService()

        XCTAssertFalse(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected v2Ready, got \(service.loadingState)")
        }
    }

    func testInit_whenPersistedFailedMigrate_bootsV1WithFailedState() {
        persist(.init(current: 1, containerState: .v2ContainerFailed))

        let service = makeService()

        XCTAssertTrue(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 1)
        XCTAssertEqual(service.versionState.containerState, .v2ContainerFailed)
        guard case .v1Ready = service.loadingState else {
            return XCTFail("Expected v1Ready, got \(service.loadingState)")
        }
    }

    func testMigrateToV2_success_setsV2Ready() async throws {
        let service = makeService()

        service.migrateToV2()
        await waitUntil { !service.isVersion1 }

        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
        XCTAssertEqual(defaults.integer(forKey: StoreService.persistedVersionKey), 2)
        XCTAssertEqual(
            defaults.string(forKey: StoreService.persistedContainerStateKey),
            "healthy"
        )
        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected v2Ready, got \(service.loadingState)")
        }
    }

    func testMigrateToV2_whenAlreadyV2_isNoOp() async throws {
        let service = makeService()
        service.migrateToV2()
        await waitUntil {
            if case .v2Ready = service.loadingState { return true }
            return false
        }
        guard case .v2Ready(let containerBefore) = service.loadingState else {
            return XCTFail("Expected v2Ready before no-op")
        }

        service.migrateToV2()

        guard case .v2Ready(let containerAfter) = service.loadingState else {
            return XCTFail("Expected v2Ready after no-op, got \(service.loadingState)")
        }
        XCTAssertTrue(containerBefore === containerAfter)
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
    }

    func testReloadContainer_onV1_rebuildsV1() throws {
        let service = makeService()
        guard case .v1Ready(let before) = service.loadingState else {
            return XCTFail("Expected v1Ready")
        }

        service.reloadContainer()

        guard case .v1Ready(let after) = service.loadingState else {
            return XCTFail("Expected v1Ready after reload, got \(service.loadingState)")
        }
        XCTAssertFalse(before === after)
        XCTAssertTrue(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 1)
        XCTAssertEqual(service.versionState.containerState, .healthy)
    }

    func testReloadContainer_onV2_rebuildsV2() async throws {
        let service = makeService()
        service.migrateToV2()
        await waitUntil {
            if case .v2Ready = service.loadingState { return true }
            return false
        }
        guard case .v2Ready(let before) = service.loadingState else {
            return XCTFail("Expected v2Ready")
        }

        service.reloadContainer()

        guard case .v2Ready(let after) = service.loadingState else {
            return XCTFail("Expected v2Ready after reload, got \(service.loadingState)")
        }
        XCTAssertFalse(before === after)
        XCTAssertFalse(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
    }

    func testMigrateToV2_whenV2ContainerFails_staysV1WithFailedState() async throws {
        let service = makeService(makeV2: { _ in throw TestContainerError.forcedFailure })
        guard case .v1Ready(let v1Before) = service.loadingState else {
            return XCTFail("Expected v1Ready before failed migrate")
        }

        service.migrateToV2()
        await waitUntil {
            service.versionState.containerState == .v2ContainerFailed
        }

        guard case .v1Ready(let v1After) = service.loadingState else {
            return XCTFail("Expected to stay on v1Ready, got \(service.loadingState)")
        }
        XCTAssertTrue(v1Before === v1After)
        XCTAssertTrue(service.isVersion1)
        XCTAssertEqual(service.versionState.current, 1)
        XCTAssertEqual(service.versionState.containerState, .v2ContainerFailed)
        XCTAssertEqual(defaults.integer(forKey: StoreService.persistedVersionKey), 1)
        XCTAssertEqual(
            defaults.string(forKey: StoreService.persistedContainerStateKey),
            "v2ContainerFailed"
        )
    }

    func testInit_whenV1ContainerFails_setsContainerFailure() {
        let service = makeService(makeV1: { _ in throw TestContainerError.forcedFailure })

        guard case .containerFailure = service.loadingState else {
            return XCTFail("Expected containerFailure, got \(service.loadingState)")
        }
        XCTAssertEqual(service.versionState.current, 1)
    }

    func testInit_whenPersistedV2ContainerFails_setsContainerFailure() {
        persist(.init(current: 2, containerState: .healthy))

        let service = makeService(makeV2: { _ in throw TestContainerError.forcedFailure })

        guard case .containerFailure = service.loadingState else {
            return XCTFail("Expected containerFailure, got \(service.loadingState)")
        }
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(defaults.integer(forKey: StoreService.persistedVersionKey), 2)
    }

    func testReloadContainer_afterPersistedV2BootFailure_retriesV2() throws {
        persist(.init(current: 2, containerState: .healthy))
        var v2ShouldFail = true
        let service = makeService(
            makeV2: { _ in
                if v2ShouldFail { throw TestContainerError.forcedFailure }
                return try TestContainers.v2()
            }
        )

        guard case .containerFailure = service.loadingState else {
            return XCTFail("Expected containerFailure on first boot")
        }

        v2ShouldFail = false
        service.reloadContainer()

        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected reload to retry V2, got \(service.loadingState)")
        }
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertFalse(service.isVersion1)
    }

    func testReloadContainer_whenFactoryFails_setsContainerFailure() throws {
        var shouldFail = false
        let service = makeService(
            makeV1: { _ in
                if shouldFail { throw TestContainerError.forcedFailure }
                return try TestContainers.v1()
            }
        )

        shouldFail = true
        service.reloadContainer()

        guard case .containerFailure = service.loadingState else {
            return XCTFail("Expected containerFailure, got \(service.loadingState)")
        }
    }

    func testMigrateToV2_whenCalledTwice_onlyRunsOnce() async throws {
        var v2Builds = 0
        let service = makeService(
            makeV2: { _ in
                v2Builds += 1
                return try TestContainers.v2()
            }
        )

        service.migrateToV2()
        service.migrateToV2()
        await waitUntil { !service.isVersion1 }

        XCTAssertEqual(v2Builds, 1)
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected v2Ready, got \(service.loadingState)")
        }
    }

    func testReadPersistedVersionState_ignoresFailedStateWhenCurrentIs2() {
        persist(.init(current: 2, containerState: .v2ContainerFailed))

        let state = StoreService.readPersistedVersionState(from: defaults)

        XCTAssertEqual(state.current, 2)
        XCTAssertEqual(state.containerState, .healthy)
    }

    func testReloadContainer_whileMigrating_isNoOp() async throws {
        let service = makeService()

        service.migrateToV2()
        service.reloadContainer()

        await waitUntil { !service.isVersion1 }

        guard case .v2Ready = service.loadingState else {
            return XCTFail("Expected migrate to finish at v2Ready, got \(service.loadingState)")
        }
        // Reload during migrate must not tear down and reboot V1 mid-flight.
        XCTAssertEqual(service.versionState.current, 2)
        XCTAssertEqual(service.versionState.containerState, .healthy)
    }

    private func persist(_ state: VersionState) {
        defaults.set(state.current, forKey: StoreService.persistedVersionKey)
        let raw: String
        switch state.containerState {
        case .healthy:
            raw = "healthy"
        case .v2ContainerFailed:
            raw = "v2ContainerFailed"
        }
        defaults.set(raw, forKey: StoreService.persistedContainerStateKey)
    }

    private func makeService(
        makeV1: ((Bool) throws -> ModelContainer)? = nil,
        makeV2: ((Bool) throws -> ModelContainer)? = nil
    ) -> StoreService {
        StoreService(
            inMemoryOnly: true,
            defaults: defaults,
            makeV1: makeV1 ?? { _ in try TestContainers.v1() },
            makeV2: makeV2 ?? { _ in try TestContainers.v2() }
        )
    }

    private func waitUntil(
        timeout: TimeInterval = 1,
        _ condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }
}
