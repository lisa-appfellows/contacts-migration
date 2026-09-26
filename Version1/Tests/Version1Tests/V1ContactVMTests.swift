//
//  V1ContactVMTests.swift
//  Version1Tests
//

import XCTest
@testable import Version1

@MainActor
final class V1ContactVMTests: XCTestCase {
    func testNewContact_defaults() {
        let vm = V1ContactVM()

        XCTAssertTrue(vm.isNewContact)
        XCTAssertEqual(vm.navTitle, "New Contact")
        XCTAssertEqual(vm.phoneLimit, 1)
        XCTAssertEqual(vm.emailLimit, 1)
        XCTAssertEqual(vm.birthdayLimit, 1)
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
        XCTAssertTrue(vm.emails.isEmpty)
        XCTAssertTrue(vm.birthdays.isEmpty)
    }

    func testInitFromModel_mapsScalarFieldsAndSingleValueCollections() {
        let birthday = Calendar.current.date(from: DateComponents(year: 1990, month: 3, day: 12))!
        let contact = V1Contact(
            firstName: "Ada",
            lastName: "Lovelace",
            company: "Analytical",
            phoneNumber: "555-0100",
            email: "ada@example.com",
            birthday: birthday,
            notes: "Note"
        )

        let vm = V1ContactVM(from: contact)

        XCTAssertFalse(vm.isNewContact)
        XCTAssertEqual(vm.navTitle, "")
        XCTAssertEqual(vm.stableId, contact.stableId)
        XCTAssertEqual(vm.firstName, "Ada")
        XCTAssertEqual(vm.lastName, "Lovelace")
        XCTAssertEqual(vm.company, "Analytical")
        XCTAssertEqual(vm.phoneNumbers, ["555-0100"])
        XCTAssertEqual(vm.emails, ["ada@example.com"])
        XCTAssertEqual(vm.birthdays, [birthday])
        XCTAssertEqual(vm.notes, "Note")
    }

    func testInitFromModel_withNilOptionalFields_usesEmptyCollections() {
        let contact = V1Contact(firstName: "Solo")
        let vm = V1ContactVM(from: contact)

        XCTAssertEqual(vm.firstName, "Solo")
        XCTAssertEqual(vm.lastName, "")
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
        XCTAssertTrue(vm.emails.isEmpty)
        XCTAssertTrue(vm.birthdays.isEmpty)
        XCTAssertEqual(vm.notes, "")
    }
}
