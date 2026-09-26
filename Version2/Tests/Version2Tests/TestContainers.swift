//
//  TestContainers.swift
//  Version2Tests
//

import SwiftData
@testable import Version2

enum TestContainers {
    static func v2() throws -> ModelContainer {
        try Version2.container(inMemoryOnly: true)
    }
}
