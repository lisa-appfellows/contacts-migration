//
//  PreviewSupport.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

#if DEBUG
import Foundation
import SwiftData

enum PreviewSupport {
    @MainActor
    static let container: ModelContainer = {
        let container = try! Version2.container(inMemoryOnly: true)
        let context = container.mainContext
        for mock in Contact.mockList {
            context.insert(mock)
        }
        try? context.save()
        return container
    }()

    @MainActor
    static var storeRepo: StoreRepository {
        .init(context: container.mainContext)
    }
}
#endif
