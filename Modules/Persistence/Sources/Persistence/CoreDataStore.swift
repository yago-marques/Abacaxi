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

    public func save(_ entity: Entity) throws {
        let context = container.viewContext
        let managedObject = try fetchManagedObject(id: entity.id, in: context) ?? (try insertManagedObject(in: context))
        map(entity, managedObject)
        try context.save()
    }

    public func fetch(id: Entity.ID) throws -> Entity? {
        try fetchManagedObject(id: id, in: container.viewContext).map(toEntity)
    }

    public func fetchAll() throws -> [Entity] {
        let request = NSFetchRequest<ManagedObject>(entityName: entityName)
        return try container.viewContext.fetch(request).map(toEntity)
    }

    public func delete(id: Entity.ID) throws {
        let context = container.viewContext
        guard let managedObject = try fetchManagedObject(id: id, in: context) else { return }
        context.delete(managedObject)
        try context.save()
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
