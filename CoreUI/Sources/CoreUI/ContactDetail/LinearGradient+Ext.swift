// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

extension LinearGradient {
    static var stroke: LinearGradient {
        LinearGradient(
            colors: [.white, .blue, .white],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var blueWash: LinearGradient {
        LinearGradient(
            colors: [.blue.opacity(0.1), .blue.opacity(0.6)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
