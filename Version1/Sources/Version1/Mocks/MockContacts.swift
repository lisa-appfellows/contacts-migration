//
//  MockContacts.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

#if DEBUG
import Foundation

extension V1Contact {
    static var mockList: [V1Contact] {
        [
            V1Contact(
                firstName: "Alice",
                lastName: "Adams",
                company: "Northwind Labs",
                phoneNumber: "555-0101",
                email: "alice.adams@example.com",
                birthday: date(year: 1990, month: 3, day: 12),
                notes: "Met at WWDC"
            ),
            V1Contact(
                firstName: "Aaron",
                lastName: "Allen",
                company: "Brightside Media",
                phoneNumber: "555-0102",
                email: "aaron.allen@example.com"
            ),
            // B
            V1Contact(
                firstName: "Bella",
                lastName: "Baker",
                company: "Baker & Co",
                phoneNumber: "555-0103",
                email: "bella.baker@example.com",
                birthday: date(year: 1988, month: 7, day: 4)
            ),
            V1Contact(
                firstName: "Brian",
                lastName: "Brooks",
                phoneNumber: "555-0104",
                email: "brian.brooks@example.com",
                notes: "Prefers text"
            ),
            V1Contact(
                firstName: "Chloe",
                lastName: "Brown",
                company: "Harbor Design",
                phoneNumber: "555-0105",
                email: "chloe.brown@example.com",
                birthday: date(year: 1995, month: 11, day: 21)
            ),
            // C
            V1Contact(
                firstName: "Carlos",
                lastName: "Carter",
                company: "Summit Fitness",
                phoneNumber: "555-0106",
                email: "carlos.carter@example.com"
            ),
            // D
            V1Contact(
                firstName: "Diana",
                lastName: "Diaz",
                company: "Diaz Consulting",
                phoneNumber: "555-0107",
                email: "diana.diaz@example.com",
                birthday: date(year: 1982, month: 1, day: 9),
                notes: "College roommate"
            ),
            // F
            V1Contact(
                firstName: "Frank",
                lastName: "Foster",
                phoneNumber: "555-0108",
                email: "frank.foster@example.com"
            ),
            // H
            V1Contact(
                firstName: "Hannah",
                lastName: "Hayes",
                company: "Lumen Studio",
                phoneNumber: "555-0109",
                email: "hannah.hayes@example.com",
                birthday: date(year: 1993, month: 5, day: 18)
            ),
            V1Contact(
                firstName: "Hector",
                lastName: "Hernandez",
                company: "River City Bank",
                phoneNumber: "555-0110",
                email: "hector.hernandez@example.com"
            ),
            V1Contact(
                company: "Hospital",
                phoneNumber: "555-0911",
                email: "admin@hospital.com"
            ),
            // J
            V1Contact(
                firstName: "Julia",
                lastName: "Johnson",
                company: "Peak Analytics",
                phoneNumber: "555-0111",
                email: "julia.johnson@example.com",
                notes: "Introduced by Hannah"
            ),
            // K
            V1Contact(
                firstName: "Kenji",
                lastName: "Kim",
                company: "Orbit Systems",
                phoneNumber: "555-0112",
                email: "kenji.kim@example.com",
                birthday: date(year: 1991, month: 9, day: 30)
            ),
            // M
            V1Contact(
                firstName: "Maria",
                lastName: "Martinez",
                company: "Verde Kitchen",
                phoneNumber: "555-0113",
                email: "maria.martinez@example.com"
            ),
            V1Contact(
                firstName: "Miles",
                lastName: "Mitchell",
                phoneNumber: "555-0114",
                email: "miles.mitchell@example.com",
                birthday: date(year: 1987, month: 2, day: 14),
                notes: "Plays tennis on Saturdays"
            ),
            V1Contact(
                firstName: "Nora",
                lastName: "Moore",
                company: "Moore Legal",
                phoneNumber: "555-0115",
                email: "nora.moore@example.com"
            ),
            // P
            V1Contact(
                firstName: "Priya",
                lastName: "Patel",
                company: "Nimbus Health",
                phoneNumber: "555-0116",
                email: "priya.patel@example.com",
                birthday: date(year: 1994, month: 8, day: 7)
            ),
            // R
            V1Contact(
                firstName: "Rafael",
                lastName: "Ramirez",
                company: "Skyline Architecture",
                phoneNumber: "555-0117",
                email: "rafael.ramirez@example.com"
            ),
            // S
            V1Contact(
                firstName: "Sophie",
                lastName: "Sullivan",
                phoneNumber: "555-0118",
                email: "sophie.sullivan@example.com",
                notes: "Book club"
            ),
            V1Contact(
                firstName: "Sora",
                lastName: "Sato",
                company: "Sakura Tea Co",
                phoneNumber: "555-0119",
                email: "sora.sato@example.com",
                birthday: date(year: 1989, month: 12, day: 3)
            ),
            // W
            V1Contact(
                firstName: "William",
                lastName: "Williams",
                company: "Williams Logistics",
                phoneNumber: "555-0120",
                email: "william.williams@example.com",
                birthday: date(year: 1979, month: 6, day: 25)
            ),
            // #
            V1Contact(
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
#endif
