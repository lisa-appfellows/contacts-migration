//
//  PhoneNumberV2.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-22.
//

import Foundation
import SwiftData

typealias PhoneNumberV2 = SchemaV2.PhoneNumber

extension SchemaV2 {
    @Model
    final class PhoneNumber {
        var id: String = UUID().uuidString
        var rawTag: String?
        var number: String?
        var rawIsPrimary: Bool?
        var contact: Contact?

        var tag: PhoneNumberTag {
            .init(rawValue: rawTag ?? "") ?? .mobile
        }

        var isPrimary: Bool {
            rawIsPrimary ?? false
        }

        var asDTO: PhoneNumberDTOV2 {
            .init(from: self)
        }
    
        init(
            rawTag: String? = nil,
            number: String? = nil,
            rawIsPrimary: Bool? = nil
        ) {
            self.id = UUID().uuidString
            self.rawTag = rawTag
            self.number = number
            self.rawIsPrimary = rawIsPrimary
        }

        init(from dto: PhoneNumberDTOV2) {
            self.id = dto.id
            self.rawTag = dto.tag.rawValue
            self.number = dto.number
            self.rawIsPrimary = dto.isPrimary
        }

        func update(from dto: PhoneNumberDTOV2) {
            if tag != dto.tag { rawTag = dto.tag.rawValue }
            if number != dto.number { number = dto.number }
            if isPrimary != dto.isPrimary { rawIsPrimary = dto.isPrimary }
        }
    }
}
