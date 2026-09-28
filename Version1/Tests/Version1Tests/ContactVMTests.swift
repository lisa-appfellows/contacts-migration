//
//  ContactVMTests.swift
//  Version1Tests
//

import XCTest
@testable import Version1

@MainActor
final class ContactVMTests: XCTestCase {
    func testNewContact_defaults() {
        let vm = ContactVM()

        XCTAssertTrue(vm.isNewContact)
        XCTAssertEqual(vm.phoneLimit, 1)
        XCTAssertEqual(vm.emailLimit, 1)
        XCTAssertEqual(vm.birthdayLimit, 1)
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
        XCTAssertTrue(vm.emails.isEmpty)
        XCTAssertTrue(vm.birthdays.isEmpty)
    }

    func testInitFromDTO_mapsScalarFieldsAndSingleValueCollections() {
        let birthday = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 12))!
        let dto = ContactDTO(
            firstName: "Ada",
            lastName: "Lovelace",
            company: "Analytical",
            phoneNumber: "555-0100",
            email: "ada@example.com",
            birthday: birthday,
            notes: "Note"
        )

        let vm = ContactVM(from: dto)

        XCTAssertFalse(vm.isNewContact)
        XCTAssertEqual(vm.stableId, dto.stableId)
        XCTAssertEqual(vm.firstName, "Ada")
        XCTAssertEqual(vm.lastName, "Lovelace")
        XCTAssertEqual(vm.company, "Analytical")
        XCTAssertEqual(vm.phoneNumbers, ["555-0100"])
        XCTAssertEqual(vm.emails, ["ada@example.com"])
        XCTAssertEqual(vm.birthdays, [birthday])
        XCTAssertEqual(vm.notes, "Note")
    }

    func testInitFromNilDTO_createsNewContact() {
        let vm = ContactVM(from: nil)

        XCTAssertTrue(vm.isNewContact)
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
        XCTAssertTrue(vm.emails.isEmpty)
        XCTAssertTrue(vm.birthdays.isEmpty)
    }

    func testInitFromDTO_withNilOptionalFields_usesEmptyCollections() {
        let dto = ContactDTO(firstName: "Solo")
        let vm = ContactVM(from: dto)

        XCTAssertEqual(vm.firstName, "Solo")
        XCTAssertEqual(vm.lastName, "")
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
        XCTAssertTrue(vm.emails.isEmpty)
        XCTAssertTrue(vm.birthdays.isEmpty)
        XCTAssertEqual(vm.notes, "")
    }

    func testDTO_roundTripsEditedFields() {
        let vm = ContactVM(
            isNewContact: false,
            firstName: "Ada",
            phoneNumbers: ["555-0100", ""],
            emails: [""],
            notes: "Note"
        )

        let dto = vm.dto
        XCTAssertEqual(dto.firstName, "Ada")
        XCTAssertEqual(dto.phoneNumber, "555-0100")
        XCTAssertNil(dto.email)
        XCTAssertEqual(dto.notes, "Note")
    }
}
