//
//  SchemaVersionTests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

final class SchemaVersionTests: XCTestCase {
    func testMigrationPlanV2_latestSchema_matchesPostMigrationCurrentVersion() {
        let identifiers = MigrationPlanV2.schemas.map { $0.versionIdentifier }
        XCTAssertEqual(identifiers, [
            SchemaV1.versionIdentifier,
            SchemaV2.versionIdentifier
        ])
        XCTAssertEqual(SchemaV2.versionIdentifier, Schema.Version(2, 0, 0))
        XCTAssertEqual(PostMigration.currentVersion, 2)
    }

    func testMigrationPlanV2_stages_doNotSkipVersions() {
        XCTAssertEqual(MigrationPlanV2.schemas.count, 2)
        XCTAssertEqual(MigrationPlanV2.stages.count, MigrationPlanV2.schemas.count - 1)
    }
}
