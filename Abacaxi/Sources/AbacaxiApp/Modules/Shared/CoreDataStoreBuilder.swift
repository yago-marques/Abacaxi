import CoreData
import Persistence
import PersistenceInterfaces

enum CoreDataStoreBuilder {
    static func make<Entity: PersistentEntityProtocol>(
        container: NSPersistentContainer,
        entityName: String,
        idKeyPath: String,
        map: @escaping (Entity, NSManagedObject) -> Void,
        toEntity: @escaping (NSManagedObject) -> Entity
    ) -> CoreDataStore<Entity, NSManagedObject> where Entity.ID: CVarArg {
        CoreDataStore(
            container: container,
            entityName: entityName,
            idKeyPath: idKeyPath,
            map: map,
            toEntity: toEntity
        )
    }
}
