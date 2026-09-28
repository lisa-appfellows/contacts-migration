//
//  PhoneDisplayFormatter.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Foundation

public enum PhoneDisplayFormatter {
    /// Formats digit runs for display. Non-standard lengths pass through unchanged.
    public static func format(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber)
        switch digits.count {
        case 7:
            return "\(digits.prefix(3))-\(digits.suffix(4))"
        case 10:
            let area = digits.prefix(3)
            let mid = digits.dropFirst(3).prefix(3)
            let last = digits.suffix(4)
            return "\(area)-\(mid)-\(last)"
        default:
            return raw
        }
    }
}
