//
//  PhoneNumber.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation
import SwiftData

typealias PhoneNumber = V2Schema.PhoneNumber

extension V2Schema {
    @Model
    public final class PhoneNumber {
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

        var asDTO: PhoneNumberDTO {
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

        init(from dto: PhoneNumberDTO) {
            self.id = dto.id
            self.rawTag = dto.tag.rawValue
            self.number = dto.number
            self.rawIsPrimary = dto.isPrimary
        }

        func update(from dto: PhoneNumberDTO) {
            if tag != dto.tag { rawTag = dto.tag.rawValue }
            if number != dto.number { number = dto.number }
            if isPrimary != dto.isPrimary { rawIsPrimary = dto.isPrimary }
        }
    }
}
