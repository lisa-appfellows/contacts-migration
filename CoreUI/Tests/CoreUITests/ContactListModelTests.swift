//
//  ContactListModelTests.swift
//  CoreUITests
//

import XCTest
@testable import CoreUI

final class ContactListModelTests: XCTestCase {
    func testSearchName_prefersLastNameThenFirstNameThenCompany() {
        XCTAssertEqual(
            ContactListModel.searchName(StubContact(firstName: "Ann", lastName: "Smith", company: "Acme")),
            "Smith"
        )
        XCTAssertEqual(
            ContactListModel.searchName(StubContact(firstName: "Ann", company: "Acme")),
            "Ann"
        )
        XCTAssertEqual(
            ContactListModel.searchName(StubContact(company: "Acme")),
            "Acme"
        )
        XCTAssertEqual(ContactListModel.searchName(StubContact()), "")
    }

    func testInit_groupsByUppercasedFirstLetterOfSearchName() {
        let model = ContactListModel(
            version: 1,
            contacts: [
                StubContact(lastName: "adams"),
                StubContact(lastName: "Brown"),
                StubContact(lastName: "baker"),
            ]
        )

        XCTAssertEqual(model.sortedKeys, ["A", "B"])
        XCTAssertEqual(model.contacts(for: "A").map { ContactListModel.searchName($0) }, ["adams"])
        XCTAssertEqual(
            model.contacts(for: "B").map { ContactListModel.searchName($0) },
            ["baker", "Brown"]
        )
    }

    func testInit_putsHashSectionLast_forMissingOrNonLetterNames() {
        let model = ContactListModel(
            version: 1,
            contacts: [
                StubContact(lastName: "Zebra"),
                StubContact(),
                StubContact(company: "123 Logistics"),
                StubContact(firstName: "Ada"),
            ]
        )

        XCTAssertEqual(model.sortedKeys, ["A", "Z", "#"])
        XCTAssertEqual(model.contacts(for: "#").count, 2)
    }

    func testInit_sortsWithinSectionCaseInsensitively() {
        let model = ContactListModel(
            version: 2,
            contacts: [
                StubContact(lastName: "zoe"),
                StubContact(lastName: "Adam"),
                StubContact(lastName: "aaron"),
            ]
        )

        XCTAssertEqual(
            model.contacts(for: "A").map { ContactListModel.searchName($0) },
            ["aaron", "Adam"]
        )
        XCTAssertEqual(model.version, 2)
    }

    func testContactsForUnknownKey_returnsEmpty() {
        let model = ContactListModel(version: 1, contacts: [StubContact(lastName: "Only")])
        XCTAssertTrue(model.contacts(for: "Z").isEmpty)
    }
}
