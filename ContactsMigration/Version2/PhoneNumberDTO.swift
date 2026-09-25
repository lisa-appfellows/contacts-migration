//
//  PhoneNumberDTO.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation

enum PhoneNumberTag: String, Codable, CaseIterable { case home, mobile, school, work }

struct PhoneNumberDTO: Identifiable, Hashable {
    let id: String
    var tag: PhoneNumberTag
    var number: String
    var isPrimary: Bool
    
    init(tag: PhoneNumberTag, number: String, isPrimary: Bool = false) {
        self.id = UUID().uuidString
        self.tag = tag
        self.number = number
        self.isPrimary = isPrimary
    }
    
    init(from model: PhoneNumber) {
        self.id = model.id
        self.tag = model.tag
        self.number = model.number ?? ""
        self.isPrimary = model.isPrimary
    }
}
