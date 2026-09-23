//
//  PhoneNumberDTOV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation

enum PhoneNumberTag: String, Codable { case home, mobile, school, work }

struct PhoneNumberDTOV2: Identifiable {
    let id: String
    var tag: PhoneNumberTag
    var number: String?
    var isPrimary: Bool
    
    init(tag: PhoneNumberTag, number: String, isPrimary: Bool = false) {
        self.id = UUID().uuidString
        self.tag = tag
        self.number = number
        self.isPrimary = isPrimary
    }
    
    init(from model: PhoneNumberV2) {
        self.id = model.id
        self.tag = model.tag
        self.number = model.number
        self.isPrimary = model.isPrimary
    }
}
