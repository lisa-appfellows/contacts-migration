//
//  VersionSettingsVMTests.swift
//  Version2Tests
//

import XCTest
@testable import Version2

@MainActor
final class VersionSettingsVMTests: XCTestCase {
    func testHealthCopy_tracksCoordinatorRepairState() {
        let coordinator = Coordinator { _ in }
        let vm = VersionSettingsVM(coordinator: coordinator)

        XCTAssertEqual(vm.versionHealth, "Healthy")
        XCTAssertTrue(vm.versionIsHealthy)
        XCTAssertEqual(vm.postMigrationStatus, "Idle")

        coordinator.repairState = .running
        XCTAssertEqual(vm.versionHealth, "Repairing")
        XCTAssertFalse(vm.versionIsHealthy)
        XCTAssertEqual(vm.postMigrationStatus, "Repairing...")

        coordinator.repairState = .failed
        XCTAssertEqual(vm.versionHealth, "Repair Failed")
        XCTAssertFalse(vm.versionIsHealthy)
        XCTAssertEqual(vm.postMigrationStatus, "Failed")
    }
}
