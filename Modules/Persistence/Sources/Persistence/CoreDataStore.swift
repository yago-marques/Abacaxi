import CoreData
import PersistenceInterfaces

public enum CoreDataStoreError: Error {
    case entityNotFound(String)
}

public final class CoreDataStore<
    Entity: PersistentEntityProtocol,
    ManagedObject: NSManagedObject
>: PersistentStoringProtocol where Entity.ID: CVarArg {
    private let container: NSPersistentContainer
    private let entityName: String
    private let idKeyPath: String
    private let map: (Entity, ManagedObject) -> Void
    private let toEntity: (ManagedObject) -> Entity

    public init(
        container: NSPersistentContainer,
        entityName: String,
        idKeyPath: String,
        map: @escaping (Entity, ManagedObject) -> Void,
        toEntity: @escaping (ManagedObject) -> Entity
    ) {
        self.container = container
        self.entityName = entityName
        self.idKeyPath = idKeyPath
        self.map = map
        self.toEntity = toEntity
    }

    public func save(_ entity: Entity) async throws {
        let entityName = entityName
        let idKeyPath = idKeyPath
        let map = map
        return try await perform { context in
            let managedObject = try Self.fetchManagedObject(
                id: entity.id,
                in: context,
                entityName: entityName,
                idKeyPath: idKeyPath
            ) ?? (try Self.insertManagedObject(in: context, entityName: entityName))
            map(entity, managedObject)
            try context.save()
        }
    }

    public func fetch(id: Entity.ID) async throws -> Entity? {
        let entityName = entityName
        let idKeyPath = idKeyPath
        let toEntity = toEntity
        return try await perform { context in
            try Self.fetchManagedObject(
                id: id,
                in: context,
                entityName: entityName,
                idKeyPath: idKeyPath
            ).map(toEntity)
        }
    }

    public func fetchAll() async throws -> [Entity] {
        let entityName = entityName
        let toEntity = toEntity
        return try await perform { context in
            let request = NSFetchRequest<ManagedObject>(entityName: entityName)
            return try context.fetch(request).map(toEntity)
        }
    }

    public func delete(id: Entity.ID) async throws {
        let entityName = entityName
        let idKeyPath = idKeyPath
        try await perform { context in
            guard let managedObject = try Self.fetchManagedObject(
                id: id,
                in: context,
                entityName: entityName,
                idKeyPath: idKeyPath
            ) else { return }
            context.delete(managedObject)
            try context.save()
        }
    }

    private func perform<Value: Sendable>(
        _ operation: @escaping (NSManagedObjectContext) throws -> Value
    ) async throws -> Value {
        let container = container
        return try await Self.perform(on: container, operation: operation)
    }

    private static func perform<Value: Sendable>(
        on container: NSPersistentContainer,
        operation: @escaping (NSManagedObjectContext) throws -> Value
    ) async throws -> Value {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    continuation.resume(returning: try operation(context))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private static func insertManagedObject(
        in context: NSManagedObjectContext,
        entityName: String
    ) throws -> ManagedObject {
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw CoreDataStoreError.entityNotFound(entityName)
        }
        return ManagedObject(entity: description, insertInto: context)
    }

    private static func fetchManagedObject(
        id: Entity.ID,
        in context: NSManagedObjectContext,
        entityName: String,
        idKeyPath: String
    ) throws -> ManagedObject? {
        let request = NSFetchRequest<ManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "%K == %@", idKeyPath, id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
