//
//  V2RouterTests.swift
//  Version2Tests
//

import SwiftData
import XCTest
@testable import Version2

@MainActor
final class V2RouterTests: XCTestCase {
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        container = try TestContainers.v2()
        context = ModelContext(container)
        context.autosaveEnabled = false
    }

    func testCreateDictionary_indexesContactsByStableId() throws {
        let ada = V2Contact(firstName: "Ada")
        let grace = V2Contact(firstName: "Grace")
        context.insert(ada)
        context.insert(grace)

        let router = V2Router()
        router.createDictionary(from: [ada, grace])

        XCTAssertEqual(router.contactDict.count, 2)
        XCTAssertEqual(router.contactDict[ada.stableId]?.firstName, "Ada")
        XCTAssertEqual(router.contactDict[grace.stableId]?.firstName, "Grace")
    }

    func testPresentEditor_withoutStableId_opensNewContactSheet() {
        let router = V2Router()

        router.presentEditor()

        guard case .editor(let vm)? = router.sheet else {
            return XCTFail("Expected editor sheet")
        }
        XCTAssertTrue(vm.isNewContact)
    }

    func testPresentEditor_withKnownStableId_opensExistingContact() throws {
        let contact = V2Contact(firstName: "Grace", lastName: "Hopper")
        context.insert(contact)

        let phone = PhoneNumber(from: PhoneNumberDTO(tag: .mobile, number: "555-0100", isPrimary: true))
        context.insert(phone)
        contact.phoneNumbers = [phone]

        let router = V2Router()
        router.createDictionary(from: [contact])

        router.presentEditor(stableId: contact.stableId)

        guard case .editor(let vm)? = router.sheet else {
            return XCTFail("Expected editor sheet")
        }
        XCTAssertFalse(vm.isNewContact)
        XCTAssertEqual(vm.stableId, contact.stableId)
        XCTAssertEqual(vm.firstName, "Grace")
        XCTAssertEqual(vm.phoneNumbers.map(\.number), ["555-0100"])
    }

    func testPresentEditor_withUnknownStableId_leavesSheetNil() throws {
        let contact = V2Contact(firstName: "Ada")
        context.insert(contact)

        let router = V2Router()
        router.createDictionary(from: [contact])

        router.presentEditor(stableId: "missing-id")

        XCTAssertNil(router.sheet)
    }
}
