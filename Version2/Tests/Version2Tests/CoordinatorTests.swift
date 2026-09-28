//
//  CoordinatorTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

@MainActor
final class CoordinatorTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testRefreshRepairs_success_setsIdle() async throws {
        let coordinator = Coordinator { _ in }

        coordinator.refreshRepairs(context: context)

        await waitUntil(timeout: 1) { coordinator.repairState == .idle }
        XCTAssertEqual(coordinator.repairState, .idle)
    }

    func testRefreshRepairs_failsThreeTimes_setsFailed() async throws {
        let coordinator = Coordinator { _ in
            throw PostMigrationError.fetchModelFailure
        }

        coordinator.refreshRepairs(context: context)

        await waitUntil(timeout: 1) { coordinator.repairState == .failed }
        XCTAssertEqual(coordinator.repairState, .failed)
    }

    func testRefreshRepairs_succeedsOnSecondAttempt_setsIdle() async throws {
        var attempts = 0
        let coordinator = Coordinator { _ in
            attempts += 1
            if attempts < 2 {
                throw PostMigrationError.fetchModelFailure
            }
        }

        coordinator.refreshRepairs(context: context)

        await waitUntil(timeout: 1) { coordinator.repairState == .idle }
        XCTAssertEqual(coordinator.repairState, .idle)
        XCTAssertEqual(attempts, 2)
    }

    func testRefreshRepairs_whileRunning_isIgnored() async throws {
        var runCount = 0
        let gate = AsyncGate()

        let coordinator = Coordinator { _ in
            runCount += 1
            await gate.wait()
        }

        coordinator.refreshRepairs(context: context)
        await waitUntil(timeout: 1) { coordinator.repairState == .running }

        coordinator.refreshRepairs(context: context)
        await gate.open()

        await waitUntil(timeout: 1) { coordinator.repairState == .idle }
        XCTAssertEqual(runCount, 1)
    }

    private func waitUntil(
        timeout: TimeInterval,
        _ condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if condition() { return }
            try? await Task.sleep(nanoseconds: 20_000_000)
        }
    }
}

private actor AsyncGate {
    private var isOpen = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func wait() async {
        if isOpen { return }
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }

    func open() {
        isOpen = true
        let pending = waiters
        waiters.removeAll()
        for waiter in pending {
            waiter.resume()
        }
    }
}
