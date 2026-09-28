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
        let container = try! Version1.container(inMemoryOnly: true)
        let repo = StoreRepository(context: container.mainContext)
        _ = repo.seedContacts()
        return container
    }()

    @MainActor
    static var storeRepo: StoreRepository {
        .init(context: container.mainContext)
    }
}
#endif
