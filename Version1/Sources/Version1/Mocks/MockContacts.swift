//
//  MockContacts.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import Foundation

extension Contact {
    static var mockList: [Contact] {
        [
            Contact(
                firstName: "Alice",
                lastName: "Adams",
                company: "Northwind Labs",
                phoneNumber: "555-0101",
                email: "alice.adams@example.com",
                birthday: date(year: 1990, month: 3, day: 12),
                notes: "Met at WWDC"
            ),
            Contact(
                firstName: "Aaron",
                lastName: "Allen",
                company: "Brightside Media",
                phoneNumber: "555-0102",
                email: "aaron.allen@example.com"
            ),
            // B
            Contact(
                firstName: "Bella",
                lastName: "Baker",
                company: "Baker & Co",
                phoneNumber: "555-0103",
                email: "bella.baker@example.com",
                birthday: date(year: 1988, month: 7, day: 4)
            ),
            Contact(
                firstName: "Brian",
                lastName: "Brooks",
                phoneNumber: "555-0104",
                email: "brian.brooks@example.com",
                notes: "Prefers text"
            ),
            Contact(
                firstName: "Chloe",
                lastName: "Brown",
                company: "Harbor Design",
                phoneNumber: "555-0105",
                email: "chloe.brown@example.com",
                birthday: date(year: 1995, month: 11, day: 21)
            ),
            // C
            Contact(
                firstName: "Carlos",
                lastName: "Carter",
                company: "Summit Fitness",
                phoneNumber: "555-0106",
                email: "carlos.carter@example.com"
            ),
            // D
            Contact(
                firstName: "Diana",
                lastName: "Diaz",
                company: "Diaz Consulting",
                phoneNumber: "555-0107",
                email: "diana.diaz@example.com",
                birthday: date(year: 1982, month: 1, day: 9),
                notes: "College roommate"
            ),
            // F
            Contact(
                firstName: "Frank",
                lastName: "Foster",
                phoneNumber: "555-0108",
                email: "frank.foster@example.com"
            ),
            // H
            Contact(
                firstName: "Hannah",
                lastName: "Hayes",
                company: "Lumen Studio",
                phoneNumber: "555-0109",
                email: "hannah.hayes@example.com",
                birthday: date(year: 1993, month: 5, day: 18)
            ),
            Contact(
                firstName: "Hector",
                lastName: "Hernandez",
                company: "River City Bank",
                phoneNumber: "555-0110",
                email: "hector.hernandez@example.com"
            ),
            Contact(
                company: "Hospital",
                phoneNumber: "555-0911",
                email: "admin@hospital.com"
            ),
            // J
            Contact(
                firstName: "Julia",
                lastName: "Johnson",
                company: "Peak Analytics",
                phoneNumber: "555-0111",
                email: "julia.johnson@example.com",
                notes: "Introduced by Hannah"
            ),
            // K
            Contact(
                firstName: "Kenji",
                lastName: "Kim",
                company: "Orbit Systems",
                phoneNumber: "555-0112",
                email: "kenji.kim@example.com",
                birthday: date(year: 1991, month: 9, day: 30)
            ),
            // M
            Contact(
                firstName: "Maria",
                lastName: "Martinez",
                company: "Verde Kitchen",
                phoneNumber: "555-0113",
                email: "maria.martinez@example.com"
            ),
            Contact(
                firstName: "Miles",
                lastName: "Mitchell",
                phoneNumber: "555-0114",
                email: "miles.mitchell@example.com",
                birthday: date(year: 1987, month: 2, day: 14),
                notes: "Plays tennis on Saturdays"
            ),
            Contact(
                firstName: "Nora",
                lastName: "Moore",
                company: "Moore Legal",
                phoneNumber: "555-0115",
                email: "nora.moore@example.com"
            ),
            // P
            Contact(
                firstName: "Priya",
                lastName: "Patel",
                company: "Nimbus Health",
                phoneNumber: "555-0116",
                email: "priya.patel@example.com",
                birthday: date(year: 1994, month: 8, day: 7)
            ),
            // R
            Contact(
                firstName: "Rafael",
                lastName: "Ramirez",
                company: "Skyline Architecture",
                phoneNumber: "555-0117",
                email: "rafael.ramirez@example.com"
            ),
            // S
            Contact(
                firstName: "Sophie",
                lastName: "Sullivan",
                phoneNumber: "555-0118",
                email: "sophie.sullivan@example.com",
                notes: "Book club"
            ),
            Contact(
                firstName: "Sora",
                lastName: "Sato",
                company: "Sakura Tea Co",
                phoneNumber: "555-0119",
                email: "sora.sato@example.com",
                birthday: date(year: 1989, month: 12, day: 3)
            ),
            // W
            Contact(
                firstName: "William",
                lastName: "Williams",
                company: "Williams Logistics",
                phoneNumber: "555-0120",
                email: "william.williams@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
            // #
            Contact(
                phoneNumber: "555-0121",
                email: "blank.blank@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
        ]
    }

    private static func date(year: Int, month: Int, day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day))!
    }
}
