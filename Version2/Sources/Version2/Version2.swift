import Core
import SwiftData
import SwiftUI
import Version1

public enum Version2 {
    public static func container(inMemoryOnly: Bool) throws -> ModelContainer {
        try ModelContainer(
            for: Schema(versionedSchema: V2Schema.self),
            migrationPlan: MigrationPlan.self,
            configurations: .init(isStoredInMemoryOnly: inMemoryOnly)
        )
    }

    public static func containerView(needsRepairs: Bool, refreshRepairsTapped: @escaping () -> Void) -> some View {
        V2ContainerView(needsRepairs: needsRepairs, refreshRepairsTapped: refreshRepairsTapped)
    }

    public static func postMigration(container: ModelContainer) -> any PostMigrationService {
        PostMigration(container: container)
    }
}

enum V2Schema: VersionedSchema {
    static let versionIdentifier: Schema.Version = .init(2, 0, 0)
    static let models: [any PersistentModel.Type] = [
        Contact.self, PhoneNumber.self
    ]
}

enum MigrationPlan: SchemaMigrationPlan {
    public static let schemas: [VersionedSchema.Type] = [
        V1Schema.self, V2Schema.self
    ]

    public static let stages: [MigrationStage] = [
        .lightweight(fromVersion: V1Schema.self, toVersion: V2Schema.self)
    ]
}
