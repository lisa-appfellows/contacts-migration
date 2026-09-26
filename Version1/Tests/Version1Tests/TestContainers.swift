//
//  TestContainers.swift
//  Version1Tests
//

import SwiftData
@testable import Version1

enum TestContainers {
    static func v1() throws -> ModelContainer {
        try Version1.container(inMemoryOnly: true)
    }
}
