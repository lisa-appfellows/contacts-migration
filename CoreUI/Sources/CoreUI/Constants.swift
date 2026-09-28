//
//  Constants.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Foundation

public enum Constants {
    public enum List {
        public static let navigationTitle = "Contacts"
        public static let emptyTitle = "No Contacts"
        public static let emptyDescription = "Add a contact to get started."
        public static let addContact = "Add Contact"
        public static let noName = "No Name"

        public static func version(_ number: Int) -> String {
            "Version \(number)"
        }
    }

    public enum Editor {
        public static let notes = "Notes"
        public static let deleteContact = "Delete Contact"
        public static let tryAgain = "Try Again"
        public static let firstName = "First Name"
        public static let lastName = "Last Name"
        public static let company = "Company"
        public static let newContact = "New Contact"
        public static let addPhoneNumber = "add phone number"
        public static let addEmail = "add email"
        public static let addBirthday = "add birthday"
        public static let phoneNumberPlaceholder = "phone number"
        public static let phonePlaceholder = "Phone"
        public static let emailPlaceholder = "email"
        public static let birthday = "birthday"
    }

    public enum Detail {
        public static let notes = "Notes"
        public static let edit = "Edit"
        public static let email = "Email"
        public static let phoneNumber = "Phone number"
        public static let birthday = "Birthday"
        public static let noName = "No Name"
        public static let unavailableTitle = "Unable to Load Contact"
        public static let unavailableDescription =
            "Something went wrong while opening your contact. Tap Reload to try again."
        public static let reload = "Reload"
    }

    public enum Container {
        public static let navigationTitle = "Contacts"
        public static let failureTitle = "Unable to Load Contacts"
        public static let failureDescription =
            "Something went wrong while opening your contacts. Tap Reload to try again."
        public static let reload = "Reload"
    }
}
