//
//  V2ContactVMTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

@MainActor
final class V2ContactVMTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testNewContact_defaults() {
        let vm = V2ContactVM()

        XCTAssertTrue(vm.isNewContact)
        XCTAssertEqual(vm.navTitle, "New Contact")
        XCTAssertEqual(vm.repairVersion, 2)
        XCTAssertTrue(vm.canEdit)
        XCTAssertNil(vm.phoneLimit)
        XCTAssertTrue(vm.phoneNumbers.isEmpty)
    }

    func testCanEdit_requiresCurrentRepairVersion() {
        XCTAssertTrue(V2ContactVM(repairVersion: PostMigration.currentVersion).canEdit)
        XCTAssertFalse(V2ContactVM(repairVersion: 1).canEdit)
    }

    func testInitFromModel_mapsPhonesAndScalarFields() throws {
        let birthday = Calendar.current.date(from: DateComponents(year: 1988, month: 7, day: 4))!
        let contact = V2Contact(
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

        let vm = V2ContactVM(from: contact)

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
        let contact = V2Contact(repairVersion: 1, firstName: "Behind")
        context.insert(contact)

        let vm = V2ContactVM(from: contact)

        XCTAssertEqual(vm.repairVersion, 1)
        XCTAssertFalse(vm.canEdit)
    }
}
