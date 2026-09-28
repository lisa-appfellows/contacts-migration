//
//  ContactDTOTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

final class ContactDTOTests: XCTestCase {
    func testAddPhoneNumber_whenNewIsPrimary_clearsExistingPrimary() {
        var dto = ContactDTO(firstName: "Primary")
        dto.addPhoneNumber(PhoneNumberDTO(tag: .mobile, number: "111", isPrimary: true))
        dto.addPhoneNumber(PhoneNumberDTO(tag: .work, number: "222", isPrimary: true))

        XCTAssertEqual(dto.phoneNumbers.count, 2)
        XCTAssertEqual(dto.phoneNumbers.filter(\.isPrimary).count, 1)
        XCTAssertEqual(dto.primaryNumber?.number, "222")
        XCTAssertEqual(dto.phoneNumbers.first { $0.number == "111" }?.isPrimary, false)
    }

    @MainActor
    func testInitFromModel_keepsLegacyPhoneOutOfPhoneNumbers() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)

        let contact = Contact(repairVersion: 1, firstName: "Legacy")
        contact.phoneNumber = "555-legacy"
        contact.phoneNumbers = []
        context.insert(contact)

        let dto = ContactDTO(from: contact)

        XCTAssertEqual(dto.phoneNumber, "555-legacy")
        XCTAssertEqual(dto.displayLegacyPhoneNumber, "555-legacy")
        XCTAssertTrue(dto.isBehindOnRepair)
        XCTAssertTrue(dto.phoneNumbers.isEmpty)
        XCTAssertTrue(contact.phoneNumbers?.isEmpty ?? true)
    }

    @MainActor
    func testDisplayLegacyPhoneNumber_nilWhenRelationshipAlreadyHasNumber() throws {
        let container = try TestContainers.v2()
        let context = ModelContext(container)

        let contact = Contact(repairVersion: 1, firstName: "Partial")
        contact.phoneNumber = "555-same"
        let existing = PhoneNumber(from: PhoneNumberDTO(tag: .work, number: "555-same", isPrimary: true))
        context.insert(existing)
        contact.phoneNumbers = [existing]
        context.insert(contact)

        let dto = ContactDTO(from: contact)

        XCTAssertEqual(dto.phoneNumber, "555-same")
        XCTAssertNil(dto.displayLegacyPhoneNumber)
        XCTAssertEqual(dto.phoneNumbers.count, 1)
        XCTAssertEqual(dto.phoneNumbers.first?.tag, .work)
    }
}
