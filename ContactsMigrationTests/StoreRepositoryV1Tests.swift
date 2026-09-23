//
//  StoreRepositoryV1Tests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

@MainActor
final class StoreRepositoryV1Tests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: StoreRepositoryV1!

    override func setUpWithError() throws {
        container = try TestContainers.v1()
        context = ModelContext(container)
        repo = StoreRepositoryV1(context: context)
    }

    func testCreateContact_saveAndFetch_matchesDTO() throws {
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

    func testUpdateContact_persistsFieldChanges() throws {
        let contact = repo.createContact(from: ContactDTOV1(firstName: "Ada", phoneNumber: "111"))
        try repo.save()

        let update = ContactDTOV1(
            firstName: "Augusta",
            lastName: "King",
            company: "Royal",
            phoneNumber: "222",
            email: "augusta@example.com",
            notes: "Updated"
        )
        repo.updateContact(contact, from: update)
        try repo.save()

        let fetched = try XCTUnwrap(try context.fetch(FetchDescriptor<ContactV1>()).first)
        XCTAssertEqual(fetched.firstName, "Augusta")
        XCTAssertEqual(fetched.lastName, "King")
        XCTAssertEqual(fetched.company, "Royal")
        XCTAssertEqual(fetched.phoneNumber, "222")
        XCTAssertEqual(fetched.email, "augusta@example.com")
        XCTAssertEqual(fetched.notes, "Updated")
        XCTAssertEqual(fetched.stableId, contact.stableId)
    }

    func testDeleteContact_removesFromStore() throws {
        let contact = repo.createContact(from: ContactDTOV1(firstName: "Temp"))
        try repo.save()
        XCTAssertEqual(try context.fetch(FetchDescriptor<ContactV1>()).count, 1)

        repo.delete(contact)
        try repo.save()

        XCTAssertTrue(try context.fetch(FetchDescriptor<ContactV1>()).isEmpty)
    }

    func testDiscard_rollsBackUnsavedCreate() throws {
        repo.createContact(from: ContactDTOV1(firstName: "Unsaved"))
        XCTAssertEqual(try context.fetch(FetchDescriptor<ContactV1>()).count, 1)

        repo.discard()

        XCTAssertTrue(try context.fetch(FetchDescriptor<ContactV1>()).isEmpty)
    }
}
