//
//  SchemaVersionTests.swift
//  Version2Tests
//

import SwiftData
import Version1
import XCTest
@testable import Version2

final class SchemaVersionTests: XCTestCase {
    func testMigrationPlan_latestSchema_matchesPostMigrationCurrentVersion() {
        let identifiers = MigrationPlan.schemas.map { $0.versionIdentifier }
        XCTAssertEqual(identifiers, [
            V1Schema.versionIdentifier,
            V2Schema.versionIdentifier
        ])
        XCTAssertEqual(V2Schema.versionIdentifier, Schema.Version(2, 0, 0))
        XCTAssertEqual(PostMigration.currentVersion, 2)
    }

    func testMigrationPlan_stages_doNotSkipVersions() {
        XCTAssertEqual(MigrationPlan.schemas.count, 2)
        XCTAssertEqual(MigrationPlan.stages.count, MigrationPlan.schemas.count - 1)
    }
}
