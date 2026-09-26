//
//  V1RouterTests.swift
//  Version1Tests
//

import XCTest
@testable import Version1

@MainActor
final class V1RouterTests: XCTestCase {
    func testCreateDictionary_indexesContactsByStableId() {
        let ada = V1Contact(firstName: "Ada")
        let grace = V1Contact(firstName: "Grace")
        let router = V1Router()

        router.createDictionary(from: [ada, grace])

        XCTAssertEqual(router.contactDict.count, 2)
        XCTAssertEqual(router.contactDict[ada.stableId]?.firstName, "Ada")
        XCTAssertEqual(router.contactDict[grace.stableId]?.firstName, "Grace")
    }

    func testPresentEditor_withoutStableId_opensNewContactSheet() {
        let router = V1Router()

        router.presentEditor()

        guard case .editor(let vm)? = router.sheet else {
            return XCTFail("Expected editor sheet")
        }
        XCTAssertTrue(vm.isNewContact)
    }

    func testPresentEditor_withKnownStableId_opensExistingContact() {
        let contact = V1Contact(firstName: "Ada", lastName: "Lovelace")
        let router = V1Router()
        router.createDictionary(from: [contact])

        router.presentEditor(stableId: contact.stableId)

        guard case .editor(let vm)? = router.sheet else {
            return XCTFail("Expected editor sheet")
        }
        XCTAssertFalse(vm.isNewContact)
        XCTAssertEqual(vm.stableId, contact.stableId)
        XCTAssertEqual(vm.firstName, "Ada")
        XCTAssertEqual(vm.lastName, "Lovelace")
    }

    func testPresentEditor_withUnknownStableId_leavesSheetNil() {
        let router = V1Router()
        router.createDictionary(from: [V1Contact(firstName: "Ada")])

        router.presentEditor(stableId: "missing-id")

        XCTAssertNil(router.sheet)
    }
}
