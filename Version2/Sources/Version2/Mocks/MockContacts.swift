//
//  MockContacts.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

#if DEBUG
import Foundation

extension Contact {
    static var mockList: [Contact] {
        [
            contact(
                firstName: "Alice",
                lastName: "Adams",
                company: "Northwind Labs",
                phones: [(.mobile, "555-0101", true)],
                email: "alice.adams@example.com",
                birthday: date(year: 1990, month: 3, day: 12),
                notes: "Met at WWDC"
            ),
            contact(
                firstName: "Aaron",
                lastName: "Allen",
                company: "Brightside Media",
                phones: [(.mobile, "555-0102", true)],
                email: "aaron.allen@example.com"
            ),
            // B
            contact(
                firstName: "Bella",
                lastName: "Baker",
                company: "Baker & Co",
                phones: [(.mobile, "555-0103", true)],
                email: "bella.baker@example.com",
                birthday: date(year: 1988, month: 7, day: 4)
            ),
            contact(
                firstName: "Brian",
                lastName: "Brooks",
                phones: [(.mobile, "555-0104", true)],
                email: "brian.brooks@example.com",
                notes: "Prefers text"
            ),
            contact(
                firstName: "Chloe",
                lastName: "Brown",
                company: "Harbor Design",
                phones: [
                    (.mobile, "555-0105", true),
                    (.work, "555-0155", false),
                ],
                email: "chloe.brown@example.com",
                birthday: date(year: 1995, month: 11, day: 21)
            ),
            // C
            contact(
                firstName: "Carlos",
                lastName: "Carter",
                company: "Summit Fitness",
                phones: [(.mobile, "555-0106", true)],
                email: "carlos.carter@example.com"
            ),
            // D
            contact(
                firstName: "Diana",
                lastName: "Diaz",
                company: "Diaz Consulting",
                phones: [(.mobile, "555-0107", true)],
                email: "diana.diaz@example.com",
                birthday: date(year: 1982, month: 1, day: 9),
                notes: "College roommate"
            ),
            // F
            contact(
                firstName: "Frank",
                lastName: "Foster",
                phones: [(.mobile, "555-0108", true)],
                email: "frank.foster@example.com"
            ),
            // H
            contact(
                firstName: "Hannah",
                lastName: "Hayes",
                company: "Lumen Studio",
                phones: [(.mobile, "555-0109", true)],
                email: "hannah.hayes@example.com",
                birthday: date(year: 1993, month: 5, day: 18)
            ),
            contact(
                firstName: "Hector",
                lastName: "Hernandez",
                company: "River City Bank",
                phones: [
                    (.mobile, "555-0110", true),
                    (.home, "555-0119", false),
                ],
                email: "hector.hernandez@example.com"
            ),
            contact(
                company: "Hospital",
                phones: [(.mobile, "555-0911", true)],
                email: "admin@hospital.com"
            ),
            // J
            contact(
                firstName: "Julia",
                lastName: "Johnson",
                company: "Peak Analytics",
                phones: [(.mobile, "555-0111", true)],
                email: "julia.johnson@example.com",
                notes: "Introduced by Hannah"
            ),
            // K
            contact(
                firstName: "Kenji",
                lastName: "Kim",
                company: "Orbit Systems",
                phones: [(.mobile, "555-0112", true)],
                email: "kenji.kim@example.com",
                birthday: date(year: 1991, month: 9, day: 30)
            ),
            // M
            contact(
                firstName: "Maria",
                lastName: "Martinez",
                company: "Verde Kitchen",
                phones: [(.mobile, "555-0113", true)],
                email: "maria.martinez@example.com"
            ),
            contact(
                firstName: "Miles",
                lastName: "Mitchell",
                phones: [(.mobile, "555-0114", true)],
                email: "miles.mitchell@example.com",
                birthday: date(year: 1987, month: 2, day: 14),
                notes: "Plays tennis on Saturdays"
            ),
            contact(
                firstName: "Nora",
                lastName: "Moore",
                company: "Moore Legal",
                phones: [(.mobile, "555-0115", true)],
                email: "nora.moore@example.com"
            ),
            // P
            contact(
                firstName: "Priya",
                lastName: "Patel",
                company: "Nimbus Health",
                phones: [(.mobile, "555-0116", true)],
                email: "priya.patel@example.com",
                birthday: date(year: 1994, month: 8, day: 7)
            ),
            // R
            contact(
                firstName: "Rafael",
                lastName: "Ramirez",
                company: "Skyline Architecture",
                phones: [(.mobile, "555-0117", true)],
                email: "rafael.ramirez@example.com"
            ),
            // S
            contact(
                firstName: "Sophie",
                lastName: "Sullivan",
                phones: [(.mobile, "555-0118", true)],
                email: "sophie.sullivan@example.com",
                notes: "Book club"
            ),
            contact(
                firstName: "Sora",
                lastName: "Sato",
                company: "Sakura Tea Co",
                phones: [(.mobile, "555-0119", true)],
                email: "sora.sato@example.com",
                birthday: date(year: 1989, month: 12, day: 3)
            ),
            // W
            contact(
                firstName: "William",
                lastName: "Williams",
                company: "Williams Logistics",
                phones: [(.mobile, "555-0120", true)],
                email: "william.williams@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
            // #
            contact(
                phones: [(.mobile, "555-0121", true)],
                email: "blank.blank@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
        ]
    }

    private static func contact(
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        phones: [(PhoneNumberTag, String, Bool)] = [],
        email: String? = nil,
        birthday: Date? = nil,
        notes: String? = nil
    ) -> Contact {
        let contact = Contact(
            firstName: firstName,
            lastName: lastName,
            company: company,
            email: email,
            birthday: birthday,
            notes: notes
        )
        contact.phoneNumbers = phones.map { tag, number, isPrimary in
            PhoneNumber(from: PhoneNumberDTO(tag: tag, number: number, isPrimary: isPrimary))
        }
        return contact
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
#endif
