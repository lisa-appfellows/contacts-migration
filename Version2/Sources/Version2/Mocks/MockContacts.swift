//
//  MockContacts.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

#if DEBUG
import Foundation

extension V2Contact {
    static var mockList: [V2Contact] {
        [
            contact(
                firstName: "Alice",
                lastName: "Adams",
                company: "Northwind Labs",
                phone: "555-0101",
                email: "alice.adams@example.com",
                birthday: date(year: 1990, month: 3, day: 12),
                notes: "Met at WWDC"
            ),
            contact(
                firstName: "Aaron",
                lastName: "Allen",
                company: "Brightside Media",
                phone: "555-0102",
                email: "aaron.allen@example.com"
            ),
            // B
            contact(
                firstName: "Bella",
                lastName: "Baker",
                company: "Baker & Co",
                phone: "555-0103",
                email: "bella.baker@example.com",
                birthday: date(year: 1988, month: 7, day: 4)
            ),
            contact(
                firstName: "Brian",
                lastName: "Brooks",
                phone: "555-0104",
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
                phone: "555-0106",
                email: "carlos.carter@example.com"
            ),
            // D
            contact(
                firstName: "Diana",
                lastName: "Diaz",
                company: "Diaz Consulting",
                phone: "555-0107",
                email: "diana.diaz@example.com",
                birthday: date(year: 1982, month: 1, day: 9),
                notes: "College roommate"
            ),
            // F
            contact(
                firstName: "Frank",
                lastName: "Foster",
                phone: "555-0108",
                email: "frank.foster@example.com"
            ),
            // H
            contact(
                firstName: "Hannah",
                lastName: "Hayes",
                company: "Lumen Studio",
                phone: "555-0109",
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
                phone: "555-0911",
                email: "admin@hospital.com"
            ),
            // J
            contact(
                firstName: "Julia",
                lastName: "Johnson",
                company: "Peak Analytics",
                phone: "555-0111",
                email: "julia.johnson@example.com",
                notes: "Introduced by Hannah"
            ),
            // K
            contact(
                firstName: "Kenji",
                lastName: "Kim",
                company: "Orbit Systems",
                phone: "555-0112",
                email: "kenji.kim@example.com",
                birthday: date(year: 1991, month: 9, day: 30)
            ),
            // M
            contact(
                firstName: "Maria",
                lastName: "Martinez",
                company: "Verde Kitchen",
                phone: "555-0113",
                email: "maria.martinez@example.com"
            ),
            contact(
                firstName: "Miles",
                lastName: "Mitchell",
                phone: "555-0114",
                email: "miles.mitchell@example.com",
                birthday: date(year: 1987, month: 2, day: 14),
                notes: "Plays tennis on Saturdays"
            ),
            contact(
                firstName: "Nora",
                lastName: "Moore",
                company: "Moore Legal",
                phone: "555-0115",
                email: "nora.moore@example.com"
            ),
            // P
            contact(
                firstName: "Priya",
                lastName: "Patel",
                company: "Nimbus Health",
                phone: "555-0116",
                email: "priya.patel@example.com",
                birthday: date(year: 1994, month: 8, day: 7)
            ),
            // R
            contact(
                firstName: "Rafael",
                lastName: "Ramirez",
                company: "Skyline Architecture",
                phone: "555-0117",
                email: "rafael.ramirez@example.com"
            ),
            // S
            contact(
                firstName: "Sophie",
                lastName: "Sullivan",
                phone: "555-0118",
                email: "sophie.sullivan@example.com",
                notes: "Book club"
            ),
            contact(
                firstName: "Sora",
                lastName: "Sato",
                company: "Sakura Tea Co",
                phone: "555-0119",
                email: "sora.sato@example.com",
                birthday: date(year: 1989, month: 12, day: 3)
            ),
            // W
            contact(
                firstName: "William",
                lastName: "Williams",
                company: "Williams Logistics",
                phone: "555-0120",
                email: "william.williams@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
            // #
            contact(
                phone: "555-0121",
                email: "blank.blank@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
        ]
    }

    private static func contact(
        firstName: String? = nil,
        lastName: String? = nil,
        company: String? = nil,
        phone: String? = nil,
        phones: [(PhoneNumberTag, String, Bool)] = [],
        email: String? = nil,
        birthday: Date? = nil,
        notes: String? = nil
    ) -> V2Contact {
        let contact = V2Contact(
            firstName: firstName,
            lastName: lastName,
            company: company,
            email: email,
            birthday: birthday,
            notes: notes
        )

        let phoneDTOs: [PhoneNumberDTO]
        if !phones.isEmpty {
            phoneDTOs = phones.map { tag, number, isPrimary in
                PhoneNumberDTO(tag: tag, number: number, isPrimary: isPrimary)
            }
        } else if let phone {
            phoneDTOs = [PhoneNumberDTO(tag: .mobile, number: phone, isPrimary: true)]
        } else {
            phoneDTOs = []
        }

        contact.phoneNumbers = phoneDTOs.map { PhoneNumber(from: $0) }
        return contact
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
#endif
