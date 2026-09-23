//
//  TestContainers.swift
//  ContactsMigrationTests
//

import SwiftData
@testable import ContactsMigration

enum TestContainers {
    static func v1() throws -> ModelContainer {
        try StoreService.containerV1(inMemoryOnly: true)
    }

    static func v2() throws -> ModelContainer {
        try StoreService.containerV2(inMemoryOnly: true)
    }
}
