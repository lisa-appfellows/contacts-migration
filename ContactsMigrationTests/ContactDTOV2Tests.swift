//
//  ContactDTOV2Tests.swift
//  ContactsMigrationTests
//

import XCTest
@testable import ContactsMigration

final class ContactDTOV2Tests: XCTestCase {
    func testAddPhoneNumber_whenNewIsPrimary_clearsExistingPrimary() {
        var dto = ContactDTOV2(firstName: "Primary")
        dto.addPhoneNumber(PhoneNumberDTOV2(tag: .mobile, number: "111", isPrimary: true))
        dto.addPhoneNumber(PhoneNumberDTOV2(tag: .work, number: "222", isPrimary: true))

        XCTAssertEqual(dto.phoneNumbers.count, 2)
        XCTAssertEqual(dto.phoneNumbers.filter(\.isPrimary).count, 1)
        XCTAssertEqual(dto.primaryNumber?.number, "222")
        XCTAssertEqual(dto.phoneNumbers.first { $0.number == "111" }?.isPrimary, false)
    }
}
