//
//  RouterTests.swift
//  Version1Tests
//

import XCTest
@testable import Version1

@MainActor
final class RouterTests: XCTestCase {
    func testSheetEditor_withNilStableId_usesNewEditorId() {
        let router = Router()
        router.presentEditor()

        XCTAssertEqual(router.sheet?.id, "editor_new")
    }

    func testSheetEditor_withStableId_usesStableIdInSheetId() {
        let router = Router()
        router.presentEditor(stableId: "abc-123")

        XCTAssertEqual(router.sheet?.id, "editor_abc-123")
    }

    func testSheetVersionSettings_hasStableId() {
        let router = Router()
        router.presentVersionSettings()

        XCTAssertEqual(router.sheet?.id, "version_settings")
    }

    func testDismissSheet_clearsSheet() {
        let router = Router()
        router.presentEditor(stableId: "abc-123")
        router.dismissSheet()

        XCTAssertNil(router.sheet)
    }

    func testPopToRoot_clearsPath() {
        let router = Router()
        router.path.append("abc-123")
        router.popToRoot()

        XCTAssertTrue(router.path.isEmpty)
    }
}
