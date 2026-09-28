//
//  ContactAvatar.swift
//
//
//  Created by Lisa Fellows on 2026-09-26.
//

import Core
import SwiftUI

public struct ContactAvatar: View {
    private let model: ContactPresentationModel
    private let size: CGFloat

    public init(contact: any ContactPresentable, size: CGFloat = 44) {
        model = .init(contact: contact)
        self.size = size
    }

    public init(model: ContactPresentationModel, size: CGFloat = 44) {
        self.model = model
        self.size = size
    }

    public var body: some View {
        Group {
            if model.isBusiness {
                Image(systemName: "building.2.fill")
                    .font(.system(size: size * 0.52))
                    .frame(width: size, height: size)
                    .foregroundStyle(.white)
                    .background(RoundedRectangle(cornerRadius: size * 0.18).fill(.blue.gradient))
            } else {
                Group {
                    if let firstInitial = model.firstInitial, let lastInitial = model.lastInitial {
                        Text(firstInitial + lastInitial)
                    } else if let firstInitial = model.firstInitial {
                        Text(firstInitial)
                    } else if let lastInitial = model.lastInitial {
                        Text(lastInitial)
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: size * 0.52))
                    }
                }
                .font(.system(size: size * 0.48, weight: .bold))
                .frame(width: size, height: size)
                .foregroundStyle(.white)
                .background(Circle().fill(.blue.gradient))
            }
        }
    }
}
