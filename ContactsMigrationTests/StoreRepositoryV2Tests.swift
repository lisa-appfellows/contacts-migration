//
//  StoreRepositoryV2Tests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

@MainActor
final class StoreRepositoryV2Tests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!
    private var repo: V2StoreRepository!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
        repo = V2StoreRepository(context: context)
    }

    // MARK: - Contact create / update / delete

    func testCreateContact_withPhones_saveAndFetch() throws {
        let mobile = PhoneNumberDTO(tag: .mobile, number: "555-0100", isPrimary: true)
        let work = PhoneNumberDTO(tag: .work, number: "555-0101")
        let dto = V2ContactDTO(
            firstName: "Grace",
            lastName: "Hopper",
            phoneNumbers: [mobile, work]
        )

        let created = repo.createContact(from: dto)
        try repo.save()

        let fetched = try context.fetch(FetchDescriptor<V2Contact>())
        XCTAssertEqual(fetched.count, 1)

        let contact = try XCTUnwrap(fetched.first)
        XCTAssertEqual(contact.stableId, created.stableId)
        XCTAssertEqual(contact.firstName, "Grace")
        XCTAssertEqual(contact.phoneNumbers?.count, 2)

        let numbers = Set((contact.phoneNumbers ?? []).compactMap(\.number))
        XCTAssertEqual(numbers, ["555-0100", "555-0101"])
        XCTAssertEqual(contact.repairVersion, 2)
    }

    func testCreateContact_withoutPhones() throws {
        let contact = repo.createContact(from: V2ContactDTO(firstName: "Solo"))
        try repo.save()

        XCTAssertEqual(contact.firstName, "Solo")
        XCTAssertTrue(contact.phoneNumbers?.isEmpty ?? true)
    }

    func testUpdateContact_updatesScalarFields() throws {
        let contact = repo.createContact(from: V2ContactDTO(firstName: "Alan"))
        try repo.save()

        let update = V2ContactDTO(
            firstName: "Alan",
            lastName: "Turing",
            company: "Bletchley",
            email: "alan@example.com",
            notes: "Updated"
        )
        try repo.updateContact(contact, from: update)
        try repo.save()

        XCTAssertEqual(contact.lastName, "Turing")
        XCTAssertEqual(contact.company, "Bletchley")
        XCTAssertEqual(contact.email, "alan@example.com")
        XCTAssertEqual(contact.notes, "Updated")
    }

    func testUpdateContact_whenRepairBehind_throws() throws {
        let contact = V2Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)
        try repo.save()

        let dto = V2ContactDTO(firstName: "Updated")
        XCTAssertThrowsError(try repo.updateContact(contact, from: dto)) { error in
            guard case RepairStateError.repairStateBehind(let version) = error else {
                return XCTFail("Unexpected error: \(error)")
            }
            XCTAssertEqual(version, 1)
        }
        XCTAssertEqual(contact.firstName, "Behind")
    }

    func testDeleteContact_removesContactAndPhones() throws {
        let contact = repo.createContact(
            from: V2ContactDTO(
                firstName: "DeleteMe",
                phoneNumbers: [PhoneNumberDTO(tag: .mobile, number: "999")]
            )
        )
        try repo.save()
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)

        repo.deleteContact(contact)
        try repo.save()

        let verify = ModelContext(container)
        verify.autosaveEnabled = false
        XCTAssertTrue(try verify.fetch(FetchDescriptor<V2Contact>()).isEmpty)
        XCTAssertTrue(try verify.fetch(FetchDescriptor<PhoneNumber>()).isEmpty)
    }

    func testDiscard_rollsBackUnsavedCreate() throws {
        repo.createContact(from: V2ContactDTO(firstName: "Unsaved"))
        XCTAssertTrue(context.hasChanges, "Insert should be pending before discard")

        repo.discard()

        XCTAssertFalse(context.hasChanges)
        XCTAssertTrue(try context.fetch(FetchDescriptor<V2Contact>()).isEmpty)
    }

    // MARK: - Phone numbers

    func testUpdatePhoneNumberList_updatesRemovesAndAdds() throws {
        let keep = PhoneNumberDTO(tag: .mobile, number: "111", isPrimary: true)
        let remove = PhoneNumberDTO(tag: .home, number: "222")
        let dto = V2ContactDTO(firstName: "Alan", phoneNumbers: [keep, remove])

        let contact = repo.createContact(from: dto)
        try repo.save()

        var keepUpdated = try XCTUnwrap(contact.phoneNumbers?.first { $0.number == "111" }?.asDTO)
        keepUpdated.number = "111-updated"
        let add = PhoneNumberDTO(tag: .work, number: "333")

        let updateDTO = V2ContactDTO(
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

    func testAddPhoneNumberDTO_appendsToContact() throws {
        let contact = repo.createContact(from: V2ContactDTO(firstName: "AddPhone"))
        try repo.save()

        try repo.addPhoneNumberDTO(
            PhoneNumberDTO(tag: .school, number: "444", isPrimary: true),
            to: contact
        )
        try repo.save()

        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(contact.phoneNumbers?.first?.number, "444")
        XCTAssertEqual(contact.phoneNumbers?.first?.tag, .school)
        XCTAssertEqual(contact.phoneNumbers?.first?.isPrimary, true)
    }

    func testAddPhoneNumberDTO_whenRepairBehind_throws() throws {
        let contact = V2Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)
        try repo.save()

        XCTAssertThrowsError(
            try repo.addPhoneNumberDTO(PhoneNumberDTO(tag: .mobile, number: "1"), to: contact)
        ) { error in
            guard case RepairStateError.repairStateBehind = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
        XCTAssertTrue(contact.phoneNumbers?.isEmpty ?? true)
    }

    func testUpdatePhoneNumber_updatesFields() throws {
        let contact = repo.createContact(
            from: V2ContactDTO(
                firstName: "Phone",
                phoneNumbers: [PhoneNumberDTO(tag: .home, number: "old")]
            )
        )
        try repo.save()
        let phone = try XCTUnwrap(contact.phoneNumbers?.first)

        var dto = phone.asDTO
        dto.tag = .work
        dto.number = "new"
        dto.isPrimary = true
        repo.updatePhoneNumber(phone, from: dto)
        try repo.save()

        XCTAssertEqual(phone.tag, .work)
        XCTAssertEqual(phone.number, "new")
        XCTAssertEqual(phone.isPrimary, true)
    }

    func testRemovePhoneNumber_deletesFromContactAndStore() throws {
        let contact = repo.createContact(
            from: V2ContactDTO(
                firstName: "Remove",
                phoneNumbers: [
                    PhoneNumberDTO(tag: .mobile, number: "keep", isPrimary: true),
                    PhoneNumberDTO(tag: .home, number: "drop")
                ]
            )
        )
        try repo.save()

        let drop = try XCTUnwrap(contact.phoneNumbers?.first { $0.number == "drop" })
        let index = try XCTUnwrap(contact.phoneNumbers?.firstIndex { $0.id == drop.id })
        try repo.removePhoneNumber(drop, at: index, from: contact)
        try repo.save()

        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(contact.phoneNumbers?.first?.number, "keep")
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }

    func testRemovePhoneNumber_whenRepairBehind_throws() throws {
        let contact = V2Contact(repairVersion: 1, firstName: "Behind")
        let phone = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "1"))
        context.insert(contact)
        context.insert(phone)
        contact.phoneNumbers = [phone]
        try repo.save()

        XCTAssertThrowsError(try repo.removePhoneNumber(phone, at: 0, from: contact)) { error in
            guard case RepairStateError.repairStateBehind = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
    }

    func testUpdatePhoneNumberList_whenRepairBehind_throws() throws {
        let contact = V2Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)
        try repo.save()

        XCTAssertThrowsError(
            try repo.updatePhoneNumberList(
                [PhoneNumberDTO(tag: .mobile, number: "1")],
                on: contact
            )
        ) { error in
            guard case RepairStateError.repairStateBehind = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testIsUpToDateOnRepair() {
        let current = V2Contact(repairVersion: 2)
        let behind = V2Contact(repairVersion: 1)
        XCTAssertTrue(repo.isUpToDateOnRepair(current))
        XCTAssertFalse(repo.isUpToDateOnRepair(behind))
    }
}
