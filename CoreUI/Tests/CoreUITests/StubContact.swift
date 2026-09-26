//
//  StubContact.swift
//  CoreUITests
//

import Core
import Foundation

struct StubContact: ContactPresentable {
    var stableId: String = UUID().uuidString
    var firstName: String?
    var lastName: String?
    var company: String?
}
