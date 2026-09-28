//
//  VersionSettingsVMTests.swift
//  Version1Tests
//

import Core
import SwiftData
import XCTest
@testable import Version1

@MainActor
final class VersionSettingsVMTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: StoreRepository!

    override func setUpWithError() throws {
        container = try TestContainers.v1()
        context = ModelContext(container)
        context.autosaveEnabled = false
        repo = StoreRepository(context: context)
    }

    func testHealthyState_copyAndMigrateTitle() {
        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(current: 1, containerState: .healthy),
            isStoreEmpty: true
        )

        XCTAssertTrue(vm.versionIsHealthy)
        XCTAssertEqual(vm.versionHealth, "Healthy")
        XCTAssertEqual(vm.migrateTitle, "Migrate to V2")
        XCTAssertEqual(vm.migrateSymbol, "arrow.right.circle.fill")
        XCTAssertEqual(vm.seedFooter, "Load a demo contact list into this V1 store.")
    }

    func testFailedContainerState_copyAndRetryTitle() {
        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(current: 1, containerState: .v2ContainerFailed),
            isStoreEmpty: false
        )

        XCTAssertFalse(vm.versionIsHealthy)
        XCTAssertEqual(vm.versionHealth, "Migration Failed")
        XCTAssertEqual(vm.migrateTitle, "Retry V2 Migration")
        XCTAssertEqual(vm.migrateSymbol, "arrow.counterclockwise.circle.fill")
    }

    func testApplyVersionState_updatesHealthCopy() {
        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(current: 1, containerState: .healthy),
            isStoreEmpty: true
        )

        vm.applyVersionState(.init(current: 1, containerState: .v2ContainerFailed))

        XCTAssertFalse(vm.versionIsHealthy)
        XCTAssertEqual(vm.migrateTitle, "Retry V2 Migration")
    }

    func testSeed_whenStoreEmpty_seedsAndMarksStoreNonEmpty() throws {
        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(),
            isStoreEmpty: true
        )

        vm.seed()

        XCTAssertFalse(vm.isStoreEmpty)
        XCTAssertEqual(vm.seedFooter, "Seeding complete.")
        XCTAssertFalse(try context.fetch(FetchDescriptor<Contact>()).isEmpty)
    }

    func testSeed_whenStoreAlreadyHasContacts_isNoOp() throws {
        repo.createContact(from: ContactDTO(firstName: "Existing"))
        try repo.save()

        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(),
            isStoreEmpty: false
        )
        let countBefore = try context.fetch(FetchDescriptor<Contact>()).count

        vm.seed()

        XCTAssertFalse(vm.isStoreEmpty)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Contact>()).count, countBefore)
        XCTAssertEqual(vm.seedFooter, "Load a demo contact list into this V1 store.")
    }

    func testBeginMigrate_setsMigratingFooter() {
        let vm = VersionSettingsVM(
            storeRepo: repo,
            versionState: .init(current: 1, containerState: .healthy),
            isStoreEmpty: true
        )

        XCTAssertFalse(vm.isMigrating)
        XCTAssertEqual(vm.migrateFooter, Constants.Settings.migrateHealthyDescription)

        vm.beginMigrate()

        XCTAssertTrue(vm.isMigrating)
        XCTAssertEqual(vm.migrateFooter, Constants.Settings.migratingDescription)
    }
}
