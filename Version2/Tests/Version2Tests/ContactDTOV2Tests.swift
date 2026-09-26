//
//  ContactDTOV2Tests.swift
//  Version2Tests
//

import XCTest
@testable import Version2

final class ContactDTOV2Tests: XCTestCase {
    func testAddPhoneNumber_whenNewIsPrimary_clearsExistingPrimary() {
        var dto = V2ContactDTO(firstName: "Primary")
        dto.addPhoneNumber(PhoneNumberDTO(tag: .mobile, number: "111", isPrimary: true))
        dto.addPhoneNumber(PhoneNumberDTO(tag: .work, number: "222", isPrimary: true))

        XCTAssertEqual(dto.phoneNumbers.count, 2)
        XCTAssertEqual(dto.phoneNumbers.filter(\.isPrimary).count, 1)
        XCTAssertEqual(dto.primaryNumber?.number, "222")
        XCTAssertEqual(dto.phoneNumbers.first { $0.number == "111" }?.isPrimary, false)
    }
}
