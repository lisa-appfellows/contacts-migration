//
//  SchemaVersionTests.swift
//  ContactsMigrationTests
//

import SwiftData
import XCTest
@testable import ContactsMigration

final class SchemaVersionTests: XCTestCase {
    func testMigrationPlanV2_latestSchema_matchesPostMigrationCurrentVersion() {
        let identifiers = V2MigrationPlan.schemas.map { $0.versionIdentifier }
        XCTAssertEqual(identifiers, [
            V1Schema.versionIdentifier,
            V2Schema.versionIdentifier
        ])
        XCTAssertEqual(V2Schema.versionIdentifier, Schema.Version(2, 0, 0))
        XCTAssertEqual(PostMigration.currentVersion, 2)
    }

    func testMigrationPlanV2_stages_doNotSkipVersions() {
        XCTAssertEqual(V2MigrationPlan.schemas.count, 2)
        XCTAssertEqual(V2MigrationPlan.stages.count, V2MigrationPlan.schemas.count - 1)
    }
}
