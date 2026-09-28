//
//  ContactDetailRepairVMTests.swift
//  Version2Tests
//
//  Test-only local retry VM. Production detail never mounts this — repairs go
//  through Coordinator on the main ModelContext only.
//

import Observation
import XCTest
@testable import Version2

enum ContactRepairUIState: Equatable {
    case idle
    case repairing
    case failed
}

/// Exercises bounded retry / Try Again messaging without a production writer path.
@MainActor
@Observable
final class ContactDetailRepairVM {
    private let runRepair: (String) async throws -> Void

    var state: ContactRepairUIState = .idle

    init(runRepair: @escaping (String) async throws -> Void) {
        self.runRepair = runRepair
    }

    func repairIfNeeded(stableId: String, repairVersion: Int) {
        guard repairVersion < PostMigration.currentVersion else {
            state = .idle
            return
        }
        guard state != .repairing else { return }

        state = .repairing

        Task {
            var attempts = 0
            while attempts < 3 {
                do {
                    try await runRepair(stableId)
                    state = .idle
                    return
                } catch {
                    attempts += 1
                }
            }
            state = .failed
        }
    }

    func tryAgain(stableId: String, repairVersion: Int) {
        state = .idle
        repairIfNeeded(stableId: stableId, repairVersion: repairVersion)
    }
}

@MainActor
final class ContactDetailRepairVMTests: XCTestCase {
    func testRepairIfNeeded_whenUpToDate_staysIdle() async {
        var ran = false
        let vm = ContactDetailRepairVM { _ in ran = true }

        vm.repairIfNeeded(stableId: "id", repairVersion: PostMigration.currentVersion)

        XCTAssertEqual(vm.state, .idle)
        XCTAssertFalse(ran)
    }

    func testRepairIfNeeded_success_setsIdle() async {
        let vm = ContactDetailRepairVM { _ in }

        vm.repairIfNeeded(stableId: "id", repairVersion: 1)

        await waitUntil(timeout: 1) { vm.state == .idle }
        XCTAssertEqual(vm.state, .idle)
    }

    func testRepairIfNeeded_failsThreeTimes_setsFailed() async {
        let vm = ContactDetailRepairVM { _ in
            throw PostMigrationError.saveFailure(stableId: "id")
        }

        vm.repairIfNeeded(stableId: "id", repairVersion: 1)

        await waitUntil(timeout: 1) { vm.state == .failed }
        XCTAssertEqual(vm.state, .failed)
    }

    func testTryAgain_retriesAfterFailure() async {
        var attempts = 0
        let vm = ContactDetailRepairVM { _ in
            attempts += 1
            if attempts < 4 {
                throw PostMigrationError.saveFailure(stableId: "id")
            }
        }

        vm.repairIfNeeded(stableId: "id", repairVersion: 1)
        await waitUntil(timeout: 1) { vm.state == .failed }
        XCTAssertEqual(attempts, 3)

        vm.tryAgain(stableId: "id", repairVersion: 1)
        await waitUntil(timeout: 1) { vm.state == .idle }
        XCTAssertEqual(vm.state, .idle)
        XCTAssertEqual(attempts, 4)
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
