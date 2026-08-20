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
        try await perform { context in
            let managedObject = try self.fetchManagedObject(id: entity.id, in: context) ?? (try self.insertManagedObject(in: context))
            self.map(entity, managedObject)
            try context.save()
        }
    }

    public func fetch(id: Entity.ID) async throws -> Entity? {
        try await perform { context in
            try self.fetchManagedObject(id: id, in: context).map(self.toEntity)
        }
    }

    public func fetchAll() async throws -> [Entity] {
        try await perform { context in
            let request = NSFetchRequest<ManagedObject>(entityName: self.entityName)
            return try context.fetch(request).map(self.toEntity)
        }
    }

    public func delete(id: Entity.ID) async throws {
        try await perform { context in
            guard let managedObject = try self.fetchManagedObject(id: id, in: context) else { return }
            context.delete(managedObject)
            try context.save()
        }
    }

    private func perform<Value: Sendable>(
        _ operation: @escaping (NSManagedObjectContext) throws -> Value
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

    private func insertManagedObject(in context: NSManagedObjectContext) throws -> ManagedObject {
        guard let description = NSEntityDescription.entity(forEntityName: entityName, in: context) else {
            throw CoreDataStoreError.entityNotFound(entityName)
        }
        return ManagedObject(entity: description, insertInto: context)
    }

    private func fetchManagedObject(id: Entity.ID, in context: NSManagedObjectContext) throws -> ManagedObject? {
        let request = NSFetchRequest<ManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "%K == %@", idKeyPath, id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
