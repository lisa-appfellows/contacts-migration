import SwiftData
import SwiftUI

public enum Version1 {
    public enum StoreEvent: Equatable { case none, v2ContainerFailed }

    public static func container(inMemoryOnly: Bool) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: V1Schema.self),
            migrationPlan: MigrationPlan.self,
            configurations: .init(isStoredInMemoryOnly: inMemoryOnly)
        )
    }

    public static func containerView(event: StoreEvent, migrateTapped: @escaping () -> Void) -> some View {
        V1ContainerView(event: event, migrateTapped: migrateTapped)
    }
}

public enum V1Schema: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)
    public static let models: [any PersistentModel.Type] = [Contact.self]
}

enum MigrationPlan: SchemaMigrationPlan {
    static let schemas: [VersionedSchema.Type] = [V1Schema.self]
    static let stages: [MigrationStage] = []
}
