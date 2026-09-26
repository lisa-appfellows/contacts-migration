//
//  ContactPresentable.swift
//  
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation

public protocol ContactPresentable {
    var stableId: String { get }
    var firstName: String? { get }
    var lastName: String? { get }
    var company: String? { get }
}
