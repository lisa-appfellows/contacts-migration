//
//  PostMigrationTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

@MainActor
final class PostMigrationTests: XCTestCase {
    func testRunIfNeeded_movesDeprecatedPhoneNumberIntoRelationship() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "Migrate")
        contact.phoneNumber = "555-9999"
        contact.phoneNumbers = []
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        XCTAssertNil(contact.phoneNumber)
        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(contact.phoneNumbers?.first?.number, "555-9999")
        XCTAssertEqual(contact.phoneNumbers?.first?.tag, .mobile)
        XCTAssertEqual(contact.phoneNumbers?.first?.isPrimary, true)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }

    func testRunIfNeeded_withoutPhoneString_onlyBumpsRepairVersion() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "NoPhone")
        contact.phoneNumber = nil
        contact.phoneNumbers = []
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertNil(contact.phoneNumber)
        XCTAssertTrue(contact.phoneNumbers?.isEmpty ?? true)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 0)
    }

    func testRunIfNeeded_whenNothingBehind_isNoOp() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 2, firstName: "Current")
        contact.phoneNumber = "should-stay"
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)
        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertEqual(contact.phoneNumber, "should-stay")
        XCTAssertTrue(contact.phoneNumbers?.isEmpty ?? true)
    }

    func testRunIfNeeded_whenPhonesAlreadyExist_doesNotMarkMigratedPhonePrimary() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "HasPhones")
        contact.phoneNumber = "legacy"
        let existing = PhoneNumber(from: PhoneNumberDTO(tag: .work, number: "work", isPrimary: true))
        context.insert(existing)
        contact.phoneNumbers = [existing]
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        let numbers = contact.phoneNumbers ?? []
        XCTAssertEqual(numbers.count, 2)
        XCTAssertNil(contact.phoneNumber)
        XCTAssertEqual(numbers.first { $0.number == "legacy" }?.isPrimary, false)
        XCTAssertEqual(numbers.first { $0.number == "work" }?.isPrimary, true)
    }

    func testRunIfNeeded_whenLegacyAlreadyInRelationship_doesNotDuplicate() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "DupRisk")
        contact.phoneNumber = "555-same"
        let existing = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-same", isPrimary: true))
        context.insert(existing)
        contact.phoneNumbers = [existing]
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)
        // Force behind again to exercise idempotent materialize under store-wide repair.
        contact.repairVersion = 1
        contact.phoneNumber = "555-same"
        try context.save()
        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertNil(contact.phoneNumber)
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(contact.phoneNumbers?.first?.number, "555-same")
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }

    func testRunIfNeeded_dedupesExistingDuplicatePhones() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "Duped")
        contact.phoneNumber = "555-dup"
        let first = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-dup", isPrimary: true))
        let second = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-dup"))
        context.insert(first)
        context.insert(second)
        contact.phoneNumbers = [first, second]
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertNil(contact.phoneNumber)
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }

    func testRunIfNeeded_twice_doesNotDuplicatePhones() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 1, firstName: "Twice")
        contact.phoneNumber = "555-once"
        contact.phoneNumbers = []
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)
        // Force behind again to simulate a bad retry without clearing phones.
        contact.repairVersion = 1
        contact.phoneNumber = "555-once"
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertNil(contact.phoneNumber)
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }

    func testRunIfNeeded_healsDuplicatesOnAlreadyMigratedContacts() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)
        context.autosaveEnabled = false

        let contact = Contact(repairVersion: 2, firstName: "AlreadyCurrent")
        contact.phoneNumber = nil
        let first = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-heal", isPrimary: true))
        let second = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-heal"))
        context.insert(first)
        context.insert(second)
        contact.phoneNumbers = [first, second]
        context.insert(contact)
        try context.save()

        try PostMigration.runIfNeeded(context: context)

        XCTAssertEqual(contact.repairVersion, 2)
        XCTAssertEqual(contact.phoneNumbers?.count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<PhoneNumber>()).count, 1)
    }
}
