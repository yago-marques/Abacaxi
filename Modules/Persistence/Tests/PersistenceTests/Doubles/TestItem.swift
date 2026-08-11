import CoreData
@testable import Persistence
import PersistenceInterfaces

struct TestItem: PersistentEntity, Equatable {
    let id: String
    let name: String
}

@objc(TestItemManagedObject)
final class TestItemManagedObject: NSManagedObject {
    @NSManaged var id: String
    @NSManaged var name: String
}

enum TestItemModel {
    static func makeContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "TestItemContainer", managedObjectModel: makeModel())
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        var loadError: Error?
        container.loadPersistentStores { _, error in
            loadError = error
        }
        precondition(loadError == nil, "Failed to load in-memory store for tests")

        return container
    }

    static func makeStore() -> CoreDataStore<TestItem, TestItemManagedObject> {
        CoreDataStore(
            container: makeContainer(),
            entityName: "TestItem",
            idKeyPath: "id",
            map: { entity, managedObject in
                managedObject.id = entity.id
                managedObject.name = entity.name
            },
            toEntity: { managedObject in
                TestItem(id: managedObject.id, name: managedObject.name)
            }
        )
    }

    private static func makeModel() -> NSManagedObjectModel {
        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .stringAttributeType

        let nameAttribute = NSAttributeDescription()
        nameAttribute.name = "name"
        nameAttribute.attributeType = .stringAttributeType

        let entity = NSEntityDescription()
        entity.name = "TestItem"
        entity.managedObjectClassName = NSStringFromClass(TestItemManagedObject.self)
        entity.properties = [idAttribute, nameAttribute]

        let model = NSManagedObjectModel()
        model.entities = [entity]
        return model
    }
}
