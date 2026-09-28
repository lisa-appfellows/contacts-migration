//
//  VersionKey.swift
//
//
//  Created by Lisa Fellows on 2026-09-25.
//

import SwiftUI

public enum ContainerState: Equatable { case healthy, v2ContainerFailed }

public struct VersionState: Equatable {
    public let current: Int
    public let containerState: ContainerState

    public init(
        current: Int = 1,
        containerState: ContainerState = .healthy
    ) {
        self.current = current
        self.containerState = containerState
    }
}

public struct VersionStateKey: EnvironmentKey {
    public static var defaultValue: VersionState = .init()
}

extension EnvironmentValues {
    public var versionState: VersionState {
        get { self[VersionStateKey.self] }
        set { self[VersionStateKey.self] = newValue }
    }
}
