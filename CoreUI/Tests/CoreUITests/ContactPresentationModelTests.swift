//
//  ContactPresentationModelTests.swift
//  CoreUITests
//

import XCTest
@testable import CoreUI

final class ContactPresentationModelTests: XCTestCase {
    func testPresentationName_fullNamePreferred() {
        let model = ContactPresentationModel(
            contact: StubContact(firstName: "Ada", lastName: "Lovelace", company: "Analytical")
        )
        XCTAssertEqual(model.presentationName, "Ada Lovelace")
    }

    func testPresentationName_fallsBackThroughFirstLastCompany() {
        XCTAssertEqual(
            ContactPresentationModel(contact: StubContact(firstName: "Ada")).presentationName,
            "Ada"
        )
        XCTAssertEqual(
            ContactPresentationModel(contact: StubContact(lastName: "Lovelace")).presentationName,
            "Lovelace"
        )
        XCTAssertEqual(
            ContactPresentationModel(contact: StubContact(company: "Analytical")).presentationName,
            "Analytical"
        )
        XCTAssertEqual(
            ContactPresentationModel(contact: StubContact()).presentationName,
            ""
        )
    }

    func testIsBusiness_onlyWhenCompanyAndNoPersonNames() {
        XCTAssertTrue(
            ContactPresentationModel(contact: StubContact(company: "Hospital")).isBusiness
        )
        XCTAssertFalse(
            ContactPresentationModel(contact: StubContact(firstName: "Ada", company: "Hospital")).isBusiness
        )
        XCTAssertFalse(
            ContactPresentationModel(contact: StubContact(lastName: "Lovelace", company: "Hospital")).isBusiness
        )
        XCTAssertFalse(
            ContactPresentationModel(contact: StubContact()).isBusiness
        )
    }

    func testInitials_uppercasedLettersOnly() {
        let both = ContactPresentationModel(
            contact: StubContact(firstName: "ada", lastName: "lovelace")
        )
        XCTAssertEqual(both.firstInitial, "A")
        XCTAssertEqual(both.lastInitial, "L")

        let nonLetter = ContactPresentationModel(
            contact: StubContact(firstName: "7ada", lastName: "*Lee")
        )
        XCTAssertNil(nonLetter.firstInitial)
        XCTAssertNil(nonLetter.lastInitial)
    }
}
