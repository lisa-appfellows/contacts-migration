//
//  StoreRepositoryV2Tests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

@MainActor
final class StoreRepositoryV2Tests: XCTestCase {
    func testCreateContact_withPhones_saveAndFetch() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        let repo = StoreRepositoryV2(context: context)

        let mobile = PhoneNumberDTOV2(tag: .mobile, number: "555-0100", isPrimary: true)
        let work = PhoneNumberDTOV2(tag: .work, number: "555-0101")
        let dto = ContactDTOV2(
            firstName: "Grace",
            lastName: "Hopper",
            phoneNumbers: [mobile, work]
        )

        let created = repo.createContact(from: dto)
        try repo.save()

        let fetched = try context.fetch(FetchDescriptor<ContactV2>())
        XCTAssertEqual(fetched.count, 1)

        let contact = try XCTUnwrap(fetched.first)
        XCTAssertEqual(contact.stableId, created.stableId)
        XCTAssertEqual(contact.firstName, "Grace")
        XCTAssertEqual(contact.phoneNumbers?.count, 2)

        let numbers = Set((contact.phoneNumbers ?? []).compactMap(\.number))
        XCTAssertEqual(numbers, ["555-0100", "555-0101"])
        XCTAssertEqual(contact.repairVersion, 2)
    }

    func testUpdatePhoneNumberList_updatesRemovesAndAdds() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        let repo = StoreRepositoryV2(context: context)

        let keep = PhoneNumberDTOV2(tag: .mobile, number: "111", isPrimary: true)
        let remove = PhoneNumberDTOV2(tag: .home, number: "222")
        let dto = ContactDTOV2(firstName: "Alan", phoneNumbers: [keep, remove])

        let contact = repo.createContact(from: dto)
        try repo.save()

        var keepUpdated = try XCTUnwrap(contact.phoneNumbers?.first { $0.number == "111" }?.asDTO)
        keepUpdated.number = "111-updated"
        let add = PhoneNumberDTOV2(tag: .work, number: "333")

        let updateDTO = ContactDTOV2(
            firstName: "Alan",
            lastName: "Turing",
            phoneNumbers: [keepUpdated, add]
        )
        try repo.updateContact(contact, from: updateDTO)
        try repo.save()

        XCTAssertEqual(contact.lastName, "Turing")
        XCTAssertEqual(contact.phoneNumbers?.count, 2)

        let numbers = Set((contact.phoneNumbers ?? []).compactMap(\.number))
        XCTAssertEqual(numbers, ["111-updated", "333"])
        XCTAssertFalse(numbers.contains("222"))
    }

    func testUpdateContact_whenRepairBehind_throws() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        let repo = StoreRepositoryV2(context: context)

        let contact = ContactV2(
            repairVersion: 1,
            firstName: "Behind"
        )
        context.insert(contact)
        try repo.save()

        let dto = ContactDTOV2(firstName: "Updated")
        XCTAssertThrowsError(try repo.updateContact(contact, from: dto)) { error in
            guard case RepairStateError.repairStateBehind(let version) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(version, 1)
        }
        XCTAssertEqual(contact.firstName, "Behind")
    }
}
