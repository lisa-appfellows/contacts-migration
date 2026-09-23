//
//  StoreRepositoryV1Tests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

@MainActor
final class StoreRepositoryV1Tests: XCTestCase {
    func testCreateContact_saveAndFetch_matchesDTO() throws {
        let container = try TestContainers.v1()
        let context = ModelContext(container)
        let repo = StoreRepositoryV1(context: context)

        let dto = ContactDTOV1(
            firstName: "Ada",
            lastName: "Lovelace",
            company: "Analytical",
            phoneNumber: "555-0100",
            email: "ada@example.com",
            notes: "Note"
        )

        let created = repo.createContact(from: dto)
        try repo.save()

        let fetched = try context.fetch(FetchDescriptor<ContactV1>())
        XCTAssertEqual(fetched.count, 1)

        let contact = try XCTUnwrap(fetched.first)
        XCTAssertEqual(contact.stableId, created.stableId)
        XCTAssertEqual(contact.stableId, dto.stableId)
        XCTAssertEqual(contact.firstName, dto.firstName)
        XCTAssertEqual(contact.lastName, dto.lastName)
        XCTAssertEqual(contact.company, dto.company)
        XCTAssertEqual(contact.phoneNumber, dto.phoneNumber)
        XCTAssertEqual(contact.email, dto.email)
        XCTAssertEqual(contact.notes, dto.notes)
        XCTAssertEqual(contact.repairVersion, 1)
    }
}
