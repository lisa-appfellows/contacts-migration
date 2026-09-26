//
//  PostMigrationTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

final class PostMigrationTests: XCTestCase {
    @MainActor
    func testRunIfNeeded_movesDeprecatedPhoneNumberIntoRelationship() async throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)

        let contact = V2Contact(repairVersion: 1, firstName: "Migrate")
        contact.phoneNumber = "555-9999"
        contact.phoneNumbers = []
        context.insert(contact)
        try context.save()

        let migration = PostMigration(container: container)
        try await migration.runIfNeeded()

        let verifyContext = ModelContext(container)
        let fetched = try verifyContext.fetch(FetchDescriptor<V2Contact>())
        let updated = try XCTUnwrap(fetched.first)

        XCTAssertNil(updated.phoneNumber)
        XCTAssertEqual(updated.repairVersion, 2)
        XCTAssertEqual(updated.phoneNumbers?.count, 1)
        XCTAssertEqual(updated.phoneNumbers?.first?.number, "555-9999")
        XCTAssertEqual(updated.phoneNumbers?.first?.tag, .mobile)
        XCTAssertEqual(updated.phoneNumbers?.first?.isPrimary, true)
    }

    @MainActor
    func testRunIfNeeded_withoutPhoneString_onlyBumpsRepairVersion() async throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)

        let contact = V2Contact(repairVersion: 1, firstName: "NoPhone")
        contact.phoneNumber = nil
        contact.phoneNumbers = []
        context.insert(contact)
        try context.save()

        let migration = PostMigration(container: container)
        try await migration.runIfNeeded()

        let verifyContext = ModelContext(container)
        let fetched = try verifyContext.fetch(FetchDescriptor<V2Contact>())
        let updated = try XCTUnwrap(fetched.first)

        XCTAssertEqual(updated.repairVersion, 2)
        XCTAssertNil(updated.phoneNumber)
        XCTAssertTrue(updated.phoneNumbers?.isEmpty ?? true)
    }
}
