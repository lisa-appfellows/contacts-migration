//
//  MockContact.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

#if DEBUG
import Core
import Foundation

public struct MockContact: ContactPresentable {
    public var stableId: String
    public var firstName: String?
    public var lastName: String?
    public var company: String?

    public init(
        stableId: String = UUID().uuidString,
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil
    ) {
        self.stableId = stableId
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
    }
}

extension MockContact {
    public static var contacts: [MockContact] {
        [
            MockContact(
                firstName: "Alice",
                lastName: "Adams",
                company: "Northwind Labs"
            ),
            MockContact(
                firstName: "Aaron",
                lastName: "Allen",
                company: "Brightside Media"
            ),
            // B
            MockContact(
                firstName: "Bella",
                lastName: "Baker",
                company: "Baker & Co"
            ),
            MockContact(
                firstName: "Brian",
                lastName: "Brooks"
            ),
            MockContact(
                firstName: "Chloe",
                lastName: "Brown",
                company: "Harbor Design"
            ),
            // C
            MockContact(
                firstName: "Carlos",
                lastName: "Carter",
                company: "Summit Fitness"
            ),
            // D
            MockContact(
                firstName: "Diana",
                lastName: "Diaz",
                company: "Diaz Consulting"
            ),
            // F
            MockContact(
                firstName: "Frank",
                lastName: "Foster"
            ),
            // H
            MockContact(
                firstName: "Hannah",
                lastName: "Hayes",
                company: "Lumen Studio"
            ),
            MockContact(
                firstName: "Hector",
                lastName: "Hernandez",
                company: "River City Bank"
            ),
            MockContact(
                company: "Hospital"
            ),
            // J
            MockContact(
                firstName: "Julia",
                lastName: "Johnson",
                company: "Peak Analytics"
            ),
            // K
            MockContact(
                firstName: "Kenji",
                lastName: "Kim",
                company: "Orbit Systems"
            ),
            // M
            MockContact(
                firstName: "Maria",
                lastName: "Martinez",
                company: "Verde Kitchen"
            ),
            MockContact(
                firstName: "Miles",
                lastName: "Mitchell"
            ),
            MockContact(
                firstName: "Nora",
                lastName: "Moore",
                company: "Moore Legal"
            ),
            // P
            MockContact(
                firstName: "Priya",
                lastName: "Patel",
                company: "Nimbus Health"
            ),
            // R
            MockContact(
                firstName: "Rafael",
                lastName: "Ramirez",
                company: "Skyline Architecture"
            ),
            // S
            MockContact(
                firstName: "Sophie",
                lastName: "Sullivan"
            ),
            MockContact(
                firstName: "Sora",
                lastName: "Sato",
                company: "Sakura Tea Co"
            ),
            // W
            MockContact(
                firstName: "William",
                lastName: "Williams",
                company: "Williams Logistics"
            ),
            // #
            MockContact()
        ]
    }
}
#endif
