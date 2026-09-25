//
//  ContactDetailComponents.swift
//  ContactsMigration
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

extension View {
    func detailViewStyle(editAction: @escaping () -> Void) -> some View {
        modifier(DetailViewStyleModifier(editAction: editAction))
    }
}

struct DetailViewStyleModifier: ViewModifier {
    let editAction: () -> Void

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(LinearGradient.blueWash)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    DetailEditToolbarButton(action: editAction)
                }
            }
    }
}

struct DetailEditToolbarButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Edit")
                .frame(height: 35)
                .padding(.horizontal)
                .foregroundStyle(.white)
                .background(Color.blue.opacity(0.5))
                .clipShape(Capsule())
        }
    }
}

struct DetailProfileIconRow: View {
    var body: some View {
        HStack {
            Spacer()
            Image(systemName: "person.fill")
                .font(.system(size: 120))
                .foregroundStyle(.white.shadow(.inner(color: .blue, radius: 1, x: -1, y: -1)))
                .frame(width: 180, height: 180)
                .background(
                    Circle()
                        .fill(.blue.gradient.opacity(0.05))
                        .strokeBorder(LinearGradient.stroke, lineWidth: 2)
                )
            Spacer()
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}

struct DetailNameRow: View {
    let firstName: String
    let lastName: String
    let company: String

    @ScaledMetric(relativeTo: .largeTitle)
    private var nameSize: CGFloat = 56

    var body: some View {
        HStack {
            Spacer()
            VStack {
                Text(firstName + " " + lastName)
                    .font(.system(size: nameSize))
                Text(company)
                    .font(.title)
            }
            .bold()
            .foregroundStyle(.white)
            .shadow(color: .blue.opacity(0.8), radius: 4)
            Spacer()
        }
        .padding(.top, 24)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden, edges: .all)
        .listRowInsets(EdgeInsets())
    }
}

struct HeaderText: View {
    let text: String
    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .textCase(.uppercase)
            .font(.caption2.bold())
    }
}

struct DetailContactMethodRow: View {
    let headerText: String
    let value: String
    let systemIcon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HeaderText(headerText)
            HStack {
                Text(value).bold()
                Spacer()
                Image(systemName: systemIcon)
            }
        }
    }

    static func phone(headerText: String, number: String) -> DetailContactMethodRow {
        .init(headerText: headerText, value: number, systemIcon: "phone.fill")
    }

    static func email(_ email: String) -> DetailContactMethodRow {
        .init(headerText: "Email", value: email, systemIcon: "envelope.fill")
    }
}

struct DetailNotesRow: View {
    let notes: String

    var body: some View {
        VStack {
            HeaderText("Notes")
            Text(notes)
                .bold()
                .frame(height: 180)
        }
    }
}
