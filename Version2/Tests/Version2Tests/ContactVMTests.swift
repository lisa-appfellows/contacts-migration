//
//  ContactVMTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

@MainActor
final class ContactVMTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testNewContact_defaults() {
        let vm = ContactVM()

        XCTAssertTrue(vm.isNewContact)
        XCTAssertEqual(vm.navTitle, "New Contact")
        XCTAssertEqual(vm.repairVersion, 2)
        XCTAssertTrue(vm.canEdit)
        XCTAssertNil(vm.phoneLimit)
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
    }

    func testCanEdit_requiresCurrentRepairVersion() {
        XCTAssertTrue(ContactVM(repairVersion: PostMigration.currentVersion).canEdit)
        XCTAssertFalse(ContactVM(repairVersion: 1).canEdit)
    }

    func testInitFromModel_mapsPhonesAndScalarFields() throws {
        let birthday = Calendar.current.date(from: DateComponents(year: 1988, month: 7, day: 4))!
        let contact = Contact(
            firstName: "Grace",
            lastName: "Hopper",
            company: "Navy",
            email: "grace@example.com",
            birthday: birthday,
            notes: "COBOL"
        )
        context.insert(contact)

        let mobile = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-0100", isPrimary: true))
        let work = PhoneNumber(from: PhoneNumberDTO(tag: .work, number: "555-0101"))
        context.insert(mobile)
        context.insert(work)
        contact.phoneNumbers = [mobile, work]

        let vm = ContactVM(from: contact)

        XCTAssertFalse(vm.isNewContact)
        XCTAssertEqual(vm.stableId, contact.stableId)
        XCTAssertEqual(vm.repairVersion, contact.repairVersion)
        XCTAssertEqual(vm.firstName, "Grace")
        XCTAssertEqual(vm.lastName, "Hopper")
        XCTAssertEqual(vm.company, "Navy")
        XCTAssertEqual(vm.emails, ["grace@example.com"])
        XCTAssertEqual(vm.birthdays, [birthday])
        XCTAssertEqual(vm.notes, "COBOL")
        XCTAssertEqual(vm.phoneNumbers.count, 2)
        XCTAssertEqual(Set(vm.phoneNumbers.map(\.number)), ["555-0100", "555-0101"])
        XCTAssertEqual(vm.phoneNumbers.first { $0.number == "555-0100" }?.tag, .mobile)
        XCTAssertEqual(vm.phoneNumbers.first { $0.number == "555-0100" }?.isPrimary, true)
    }

    func testInitFromModel_whenBehindOnRepair_cannotEdit() throws {
        let contact = Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)

        let vm = ContactVM(from: contact)

        XCTAssertEqual(vm.repairVersion, 1)
        XCTAssertFalse(vm.canEdit)
    }

    func testDTO_roundTripFromContactVM() {
        let phones = [
            PhoneNumberDTO(tag: .mobile, number: "555-0100", isPrimary: true),
            PhoneNumberDTO(tag: .work, number: "555-0101"),
        ]
        let vm = ContactVM(
            isNewContact: false,
            stableId: "stable-1",
            repairVersion: 2,
            firstName: "Ada",
            lastName: "Lovelace",
            company: "Analytical",
            phoneNumbers: phones + [.init(tag: .home, number: "")],
            emails: ["ada@example.com", ""],
            notes: "Notes"
        )

        let dto = vm.dto

        XCTAssertEqual(dto.stableId, "stable-1")
        XCTAssertEqual(dto.repairVersion, 2)
        XCTAssertEqual(dto.firstName, "Ada")
        XCTAssertEqual(dto.lastName, "Lovelace")
        XCTAssertEqual(dto.company, "Analytical")
        XCTAssertEqual(dto.email, "ada@example.com")
        XCTAssertEqual(dto.notes, "Notes")
        XCTAssertEqual(dto.phoneNumbers.map(\.number), ["555-0100", "555-0101"])

        let restored = ContactVM(from: dto)
        XCTAssertFalse(restored.isNewContact)
        XCTAssertEqual(restored.stableId, "stable-1")
        XCTAssertEqual(restored.firstName, "Ada")
        XCTAssertEqual(restored.phoneNumbers.map(\.number), ["555-0100", "555-0101"])
        XCTAssertTrue(restored.canEdit)
    }
}
