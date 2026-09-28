//
//  StoreRepositoryTests.swift
//  Version1Tests
//

import SwiftData
import XCTest
@testable import Version1

@MainActor
final class StoreRepositoryTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: StoreRepository!

    override func setUpWithError() throws {
        container = try TestContainers.v1()
        context = ModelContext(container)
        context.autosaveEnabled = false
        repo = StoreRepository(context: context)
    }

    func testCreateContact_saveAndFetch_matchesDTO() throws {
        let dto = ContactDTO(
            firstName: "Ada",
            lastName: "Lovelace",
            company: "Analytical",
            phoneNumber: "555-0100",
            email: "ada@example.com",
            notes: "Note"
        )

        let created = repo.createContact(from: dto)
        try repo.save()

        let fetched = try context.fetch(FetchDescriptor<Contact>())
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

    func testFetchContact_returnsMatchingStableId() throws {
        let dto = ContactDTO(firstName: "Ada")
        repo.createContact(from: dto)
        try repo.save()

        let fetched = try XCTUnwrap(repo.fetchContact(stableId: dto.stableId))
        XCTAssertEqual(fetched.firstName, "Ada")
        XCTAssertNil(repo.fetchContact(stableId: "missing-id"))
    }

    func testUpdateContact_persistsFieldChanges() throws {
        let created = repo.createContact(from: ContactDTO(firstName: "Ada", phoneNumber: "111"))
        try repo.save()

        let update = ContactDTO(
            stableId: created.stableId,
            firstName: "Augusta",
            lastName: "King",
            company: "Royal",
            phoneNumber: "222",
            email: "augusta@example.com",
            notes: "Updated"
        )
        XCTAssertTrue(repo.updateContact(from: update))
        try repo.save()

        let fetched = try XCTUnwrap(try context.fetch(FetchDescriptor<Contact>()).first)
        XCTAssertEqual(fetched.firstName, "Augusta")
        XCTAssertEqual(fetched.lastName, "King")
        XCTAssertEqual(fetched.company, "Royal")
        XCTAssertEqual(fetched.phoneNumber, "222")
        XCTAssertEqual(fetched.email, "augusta@example.com")
        XCTAssertEqual(fetched.notes, "Updated")
        XCTAssertEqual(fetched.stableId, created.stableId)
    }

    func testUpdateContact_whenMissing_returnsFalse() {
        let dto = ContactDTO(stableId: "missing-id", firstName: "Ghost")
        XCTAssertFalse(repo.updateContact(from: dto))
    }

    func testDeleteContact_removesFromStore() throws {
        let created = repo.createContact(from: ContactDTO(firstName: "Temp"))
        try repo.save()
        XCTAssertEqual(try context.fetch(FetchDescriptor<Contact>()).count, 1)

        XCTAssertTrue(repo.deleteContact(from: ContactDTO(stableId: created.stableId)))
        try repo.save()

        XCTAssertTrue(try context.fetch(FetchDescriptor<Contact>()).isEmpty)
    }

    func testDeleteContact_whenMissing_returnsFalse() {
        XCTAssertFalse(repo.deleteContact(from: ContactDTO(stableId: "missing-id")))
    }

    func testDiscard_rollsBackUnsavedCreate() throws {
        repo.createContact(from: ContactDTO(firstName: "Unsaved"))
        XCTAssertTrue(context.hasChanges, "Insert should be pending before discard")

        repo.discard()

        XCTAssertFalse(context.hasChanges)
        XCTAssertTrue(try context.fetch(FetchDescriptor<Contact>()).isEmpty)
    }

    func testSeedContacts_whenEmpty_insertsMocks() throws {
        XCTAssertTrue(try context.fetch(FetchDescriptor<Contact>()).isEmpty)

        XCTAssertTrue(repo.seedContacts())

        let fetched = try context.fetch(FetchDescriptor<Contact>())
        XCTAssertEqual(fetched.count, Contact.mockList.count)
        XCTAssertTrue(fetched.contains { $0.firstName == "Alice" })
    }

    func testSeedContacts_whenNonEmpty_skipsAndReturnsTrue() throws {
        repo.createContact(from: ContactDTO(firstName: "Existing"))
        try repo.save()

        XCTAssertTrue(repo.seedContacts())
        XCTAssertEqual(try context.fetch(FetchDescriptor<Contact>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Contact>()).first?.firstName, "Existing")
    }
}
